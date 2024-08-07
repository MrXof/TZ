//
//  DataTask.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 10.02.2021.
//

import Foundation

final class DataTask<T>: Hashable, DisposeBagOwning {
  
  
  private(set) var disposeBag = DisposeBag()
  
  private(set) var isCompleted = false
  
  let completion = Pipe<Result<T, Error>>()
  
  let uuid = UUID()
  
  var cancelAction: (() -> Void)!
  var resumeAction: (() -> Void)!
  var destructor: (() -> Void)?
  
  private var subscriptionForCompletion: Subscription?
  
  init() {
    subscriptionForCompletion = completion.observe { [weak self] _ in
      self?.isCompleted = true
    }
  }
  
  func cancel() {
    cancelAction()
  }
  
  func hash(into hasher: inout Hasher) {
    uuid.hash(into: &hasher)
  }
  
  func complete(with result: Result<T, Error>) {
    completion.send(result)
    destructor?()
  }
  
  // TODO: memory leaks
  func flatMap<U>(_ produceNextTask: @escaping (T) -> DataTask<U>) -> DataTask<U> {
    let newTask = DataTask<U>()
    
    self.completion.observe { result in
      if let error = result.error {
        newTask.completion.send(.failure(error))
      } else if let t = result.success {
        let intermediateTask = produceNextTask(t)
        intermediateTask.completion.observe { newTask.completion.send($0) }.owned(by: self)
        intermediateTask.resume()
      }
    }
    
    newTask.resumeAction = {
      self.resume()
    }
    
    return newTask
  }
  
  // TODO: memory leaks
  func compactMap(_ produceNextTask: @escaping (T) -> DataTask<T>?) -> DataTask<T> {
    let newTask = DataTask<T>()
    
    self.completion.observe { result in
      if let error = result.error {
        newTask.completion.send(.failure(error))
      } else if let t = result.success {
        if let intermediateTask = produceNextTask(t) {
          intermediateTask.completion.observe { newTask.completion.send($0) }.owned(by: self)
          intermediateTask.resume()
        } else {
          newTask.completion.send(.success(t))
        }
      }
    }
    
    newTask.resumeAction = {
      self.resume()
    }
    
    return newTask
  }
  
  // TODO: memory leaks
  func map<U>(_ transform: @escaping (T) -> U) -> DataTask<U> {
    let newTask = DataTask<U>()

    self.completion.observe { result in
      if let error = result.error {
        newTask.completion.send(.failure(error))
      } else if let t = result.success {
        let u = transform(t)
        newTask.completion.send(.success(u))
      }
    }

    newTask.resumeAction = {
      self.resume()
    }

    return newTask
  }
  
  func resume() {
    resumeAction?()
  }
  
}

extension DataTask: Equatable {
  
  static func == (lhs: DataTask, rhs: DataTask) -> Bool {
    lhs.uuid == rhs.uuid
  }
  
}

struct AnyDataTask: Hashable {
  
  let task: Any
  let uuid: UUID
  
  var isCompleted: Bool {
    _isCompleted()
  }
  
  var destructor: (() -> Void)?
    
  private let _isCompleted: () -> Bool
  
  func hash(into hasher: inout Hasher) {
    uuid.hash(into: &hasher)
  }
  
  static func ==(lhs: AnyDataTask, rhs: AnyDataTask) -> Bool {
    lhs.uuid == rhs.uuid
  }
  
  fileprivate init(task: Any,
                   uid: UUID,
                   isCompleted: @escaping () -> Bool,
                   destructor: (() -> Void)?) {
    self.task = task
    self.uuid = uid
    _isCompleted = isCompleted
  }
  
}

extension DataTask {
  
  func asAnyTask() -> AnyDataTask {
    AnyDataTask(task: self,
                uid: uuid,
                isCompleted: { [weak self] in
      self?.isCompleted ?? true
    }, destructor: self.destructor)
  }
  
}

// TODO: memory leaks

func zip<T, U>(_ t1: DataTask<T>, _ t2: DataTask<U>) -> DataTask<(T, U)> {
  let newTask = DataTask<(T, U)>()

  var success1: T?
  var success2: U?

  t1.completion.observe { result in
    if let success = result.success {
      success1 = success
    } else if let error = result.error {
      newTask.completion.send(.failure(error))
    }

    zip(success1, success2) { t, u in
      newTask.completion.send(.success((t, u)))
    }
  }.owned(by: newTask)

  t2.completion.observe { result in
    if let success = result.success {
      success2 = success
    } else if let error = result.error {
      newTask.completion.send(.failure(error))
    }

    zip(success1, success2) { t, u in
      newTask.completion.send(.success((t, u)))
    }
  }.owned(by: newTask)

  newTask.resumeAction = {
    t1.resume()
    t2.resume()
  }

  return newTask

}

func zip(tasks: DataTask<Void>...) -> DataTask<Void> {
  let newTask = DataTask<Void>()
  
  var completions: [Void?] = tasks.map { _ in nil }
  
  tasks.enumerated().forEach { index, task in
    task.completion.observe { result in
      if let success = result.success {
        completions[index] = success
      } else if let error = result.error {
        newTask.completion.send(.failure(error))
      }
      if completions.compactMap(id).count == completions.count {
        newTask.completion.send(.success(()))
      }
    }.owned(by: newTask)
  }
  
  newTask.resumeAction = { tasks.forEach { $0.resume() }}
  newTask.cancelAction = { tasks.forEach { $0.cancel() }}
  
  return newTask
  
}

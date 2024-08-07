//
//  CompositeRequestExecutor.swift
//  OneCourt
//
//  Created by Oleksii Chernysh on 06.08.2021.
//

import Foundation

final class CompositeRequestExecutor: Service, RequestExecuting {
  
  private var tasks = Set<AnyDataTask>()

  var environment: ServiceLocator! {
    didSet {
      [mockExecutor, actualExecutor]
        .compactMap { $0 as? Service }
        .forEach { var service = $0
          service.environment = environment
        }
    }
  }
  
  private let mockExecutor: RequestExecuting?
  private let actualExecutor: RequestExecuting
  
  init(mockExecutor: RequestExecuting? = nil,
       actualExecutor: RequestExecuting) {
    self.mockExecutor = mockExecutor
    self.actualExecutor = actualExecutor
  }
  
  func takeOff() {
    [mockExecutor, actualExecutor]
      .compactMap { $0 as? Service }
      .forEach { $0.takeOff() }
  }
  
  func prepareToClose() {
    [mockExecutor, actualExecutor]
      .compactMap { $0 as? Service }
      .forEach { $0.prepareToClose() }
  }
  
  func execute<T>(_ request: Request<T>) -> DataTask<T>? {
    produceTask(with: request) {
      self.actualExecutor.execute($0)
    }
  }
  
  func dataTask<T>(for request: Request<T>) -> DataTask<T>? {
    produceTask(with: request) {
      self.actualExecutor.dataTask(for: $0)
    }
  }
  
  func produceTask<T>(with request: Request<T>,
                      method: (Request<T>) -> DataTask<T>?) -> DataTask<T>? {
    //    #if DEBUG
        if let mockExecutor = mockExecutor,
           let mockedTask = mockExecutor.execute(request) {
          return mockedTask
        }
    //    #endif

        let checker: ReachabilityChecker = environment.getService()
        let isReachable = checker.isReachable.value
        
        if !isReachable {
          let dataTask = DataTask<T>()
          tasks.insert(dataTask.asAnyTask())
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dataTask.completion.send(.failure(ConnectionError(code: 601)))
          }
          return dataTask
        }
    
    return method(request)
  }
  
  
}

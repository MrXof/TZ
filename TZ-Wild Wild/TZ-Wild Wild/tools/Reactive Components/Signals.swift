//
//  Signals.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 10.12.2020.
//

import Foundation
import Combine

struct Subscription {
  
  let dispose: () -> Void
  
}

extension Subscription {
  
  @discardableResult
  func owned(by owner: DisposeBagOwning) -> Subscription {
    owner.disposeBag.add(self)
    return self
  }
  
}

extension AnyCancellable {
  
  @discardableResult
  func owned(by owner: DisposeBagOwning) -> AnyCancellable {
    owner.disposeBag.add(self)
    return self
  }
  
}

class Signal<T> {
  
  fileprivate var deinitJobs = [() -> Void]()
  private var observerConnection: (() -> T?)?
  private var subscriptions = [String: (T) -> Void]()
  
  @discardableResult
  func observe(_ callback: @escaping (T) -> Void) -> Subscription {
    let subscription = _observe(callback)
    
    if let t = observerConnection?() {
      callback(t)
    } else {
      if let value = (self as? Observable<T>)?.value {
        callback(value)
      }
    }
    
    return subscription
  }
  
  private func _observe(_ callback: @escaping (T) -> Void) -> Subscription {
    let token = UUID().uuidString
    subscriptions[token] = callback
    
    return .init { self.unsubscribe(withToken: token) }
  }
  
  func unsubscribe(withToken token: String) {
    subscriptions[token] = nil
  }
  
  fileprivate func notifyObservers(with value: T) {
    subscriptions.values.forEach { $0(value) }
  }
  
}

final class Pipe<T>: Signal<T> {
  
  override init() {}
  
  func send(_ value: T) {
    notifyObservers(with: value)
  }
  
}

@propertyWrapper
final class Observable<T>: Signal<T> {
  
  var wrappedValue: T {
    value
  }
  
  var isEnabled = true
  
  var value: T {
    didSet {
      if isEnabled {
        notifyObservers(with: value)
      }
    }
  }
  
  init(_ value: T) {
    self.value = value
  }
  
}

extension Observable where T == Bool {
  
  func toggle() {
    value = !value
  }
  
}

extension Observable {
  
  func set<U>(_ keyPath: WritableKeyPath<T, U>, _ propertyValue: U) {
    var writableValue = value
    writableValue[keyPath: keyPath] = propertyValue
    value = writableValue
  }
  
}

extension Signal {
  func map<U>(_ f: @escaping (T) -> U) -> Signal<U> {
    let pipe = Pipe<U>()
    
    let subscription = self._observe { [weak pipe] t in
      pipe?.send(f(t))
    }
    
    _chain(pipe, f: f)
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
  func filter(_ f: @escaping (T) -> Bool) -> Signal<T> {
    let pipe = Pipe<T>()
    
    
    let subscription = self._observe { [weak pipe] t in
      if f(t) == true {
        pipe?.send(t)
      }
    }
    
    pipe.observerConnection = { [weak self] in
      if let observable = self as? Observable<T> {
        if f(observable.value) == true {
          return observable.value
        }
      } else {
        if let p = self as? Pipe<T>, let connectedValue = p.observerConnection?() {
          if f(connectedValue) == true {
            return connectedValue
          }
        }
      }
      return nil
    }
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
  func deliver(on queue: DispatchQueue) -> Signal<T> {
    let pipe = Pipe<T>()
    
    let subscription = self._observe { [weak pipe] t in
      queue.async { pipe?.send(t) }
    }
    
    _chain(pipe, f: id)
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
  func skip(_ n: Int) -> Signal<T> {
    guard  n > 0 else {
      return self
    }
    
    let pipe = Pipe<T>()
    
    var counter = 0
    
    let subscription = self._observe { [weak pipe] t in
      if counter >= n {
        pipe?.send(t)
      } else {
        counter += 1
      }
    }
    
    pipe.observerConnection = { [weak self] in
      if let observable = self as? Observable<T> {
        if counter >= n {
          return observable.value
        } else {
          counter += 1
          return nil
        }
      } else {
        if let p = self as? Pipe<T>, let connectedValue = p.observerConnection?() {
          if counter >= n {
            return connectedValue
          } else {
            counter += 1
            return nil
          }
        }
      }
      return nil
    }
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
  fileprivate func _chain<U>(_ child: Signal<U>, f: @escaping (T) -> U) {
    child.observerConnection = { [weak self] in
      if let observable = self as? Observable<T> {
        return f(observable.value)
      } else {
        if let p = self as? Pipe<T>, let connectedValue = p.observerConnection?() {
          return f(connectedValue)
        }
      }
      return nil
    }
  }
  
}

extension Observable {
  
  func get<U>(_ keyPath: KeyPath<T, U>) -> Observable<U> {
    let pipe = Observable<U>(self.value[keyPath: keyPath])
    
    let f: ((T) -> U) = {
      $0[keyPath: keyPath]
    }
    
    let subscription = self.observe { [weak pipe] t in
      pipe?.value = f(t)
    }
    
    _chain(pipe, f: f)
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
  func get<U>(_ f: @escaping (T) -> U) -> Observable<U> {
    let pipe = Observable<U>(f(self.value))
    
    let subscription = self.observe { [weak pipe] t in
      pipe?.value = f(t)
    }
    
    _chain(pipe, f: f)
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
  func compactMap<U>(_ f: @escaping (T) -> U?) -> Observable<U?> {
    let pipe = Observable<U?>(f(self.value))
    
    
    let subscription = self.observe { [weak pipe] t in
      guard let newValue = f(t) else { return }
      
      pipe?.value = newValue
    }
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
  func combine<U>(with signal: Observable<U>) -> Observable<(T, U)> {
    let pipe = Observable<(T, U)>((value, signal.value))
    
    let subscriptionFirst = self.observe { [weak pipe, weak signal] in
      guard let signal else { return }
      
      pipe?.value = ($0, signal.value)
    }
    
    let subscriptionSecond = signal.observe { [weak pipe, weak self] in
      guard let self else { return }
      
      pipe?.value = (self.value, $0)
    }
    
    pipe.deinitJobs.append {
      subscriptionFirst.dispose()
      subscriptionSecond.dispose()
    }
    
    return pipe
  }
  
  func withPrevValue() -> Observable<(new: T, old: T)> {
    let pipe = Observable<(new: T, old: T)>((new: self.value, old: self.value))
    
    let subscription = self.observe { [weak pipe] new in
      guard let pipe else { return }
      
      pipe.value = (new: new, old: pipe.value.new)
    }
    
    pipe.deinitJobs.append {
      subscription.dispose()
    }
    
    return pipe
  }
  
}

protocol DisposeBagOwning {
  var disposeBag: DisposeBag { get }
}

extension NSObject: DisposeBagOwning {
  private static var disposeBagKey: UInt8 = 0
  
  var disposeBag: DisposeBag {
    if let bag = objc_getAssociatedObject(self, &NSObject.disposeBagKey) as? DisposeBag {
      return bag
    } else {
      let bag = DisposeBag()
      objc_setAssociatedObject(self,
                               &NSObject.disposeBagKey,
                               bag,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return bag
    }
  }
  
}

final class DisposeBag {
  
  private var subscriptions = [Subscription]()
  private var combineSubscriptions: [AnyCancellable] = []
  
  func add(_ subscription: Subscription) {
    subscriptions.append(subscription)
  }
  
  func add(_ subscription: AnyCancellable) {
    combineSubscriptions.append(subscription)
  }
  
  func drain() {
    subscriptions.forEach { $0.dispose() }
    combineSubscriptions.forEach { $0.cancel() }
    combineSubscriptions = []
  }
  
}

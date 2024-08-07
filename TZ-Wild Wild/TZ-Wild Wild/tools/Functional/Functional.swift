//
//  Functional.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import Foundation

@discardableResult
func with<T>(_ value: T, operation: (T) -> Void) -> T {
  operation(value)
  
  return value
}

precedencegroup ForwardApplication {
  associativity: left
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator |>: ForwardApplication

func |> <A, B>(argument: A, function: (A) -> B) -> B {
  function(argument)
}

infix operator >>>: ForwardComposition

func >>> <A, B, C>(f:  @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
{ g(f($0)) }
}

func id<T>(_ t: T) -> T { t }

func zip<T, U>(_ t: T?, _ u: U?, _ block: (T, U) -> Void) {
  if let t = t, let u = u {
    block(t, u)
  }
}

func zip<T, U>(_ t: T?, _ u: U?) -> ((T, U) -> Void) -> Void {
  { f in
    zip(t, u) { f($0, $1) }
  }
}

func repeatTimes(_ times: Int, action: () -> Void) {
  for _ in 0..<times {
    action()
  }
}

public func their<T, U: Comparable>(_ keyPath: KeyPath<T, U>) -> (T, T) -> Bool {
    return { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
}

struct Once {
  
  private var onceFlag = false
  private let block: () -> Void
  
  init(_ block: @escaping () -> Void) {
    self.block = block
  }
  
  mutating func execute() {
    guard !onceFlag else { return }
    defer { onceFlag.toggle() }
    
    block()
  }
  
}

final class After {
  
  private var action: (() -> Void)?
  
  init(delay: TimeInterval, action: @escaping () -> Void) {
    self.action = action
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      guard let self = self else { return }
      self.action?()
    }
  }
  
  func cancel() {
    action = nil
  }
  
}

func flatten<T>(_ object: T, _ f: (T) -> [T]) -> [T] {
  f(object)
    .map { flatten($0, f) }
    .reduce([object], +)
}

func get<T, U>(_ keyPath: KeyPath<T, U>) -> (T) -> U {
  return { $0[keyPath: keyPath] }
}

func set<T, U>(_ keyPath: WritableKeyPath<T, U>, _ value: U) -> (inout T) -> Void  {
  { t in t[keyPath: keyPath] = value }
}

func flag<T>(_ keyPath: WritableKeyPath<T, Bool>) -> (inout T) -> Void  {
  { t in t[keyPath: keyPath] = true }
}

func unflag<T>(_ keyPath: WritableKeyPath<T, Bool>) -> (inout T) -> Void  {
  { t in t[keyPath: keyPath] = false }
}

func toggle<T>(_ keyPath: WritableKeyPath<T, Bool>) -> (inout T) -> Void  {
  { t in t[keyPath: keyPath] = !t[keyPath: keyPath] }
}

func increment<T>(_ keyPath: WritableKeyPath<T, Int>) -> (inout T) -> Void  {
  { t in t[keyPath: keyPath] += t[keyPath: keyPath] }
}

func decrement<T>(_ keyPath: WritableKeyPath<T, Int>) -> (inout T) -> Void  {
  { t in t[keyPath: keyPath] -= t[keyPath: keyPath] }
}

func insert<T, U>(_ keyPath: WritableKeyPath<T, Set<U>>,
                  _ object: U) -> (inout T) -> Void  {
  { t in
    var objects = t[keyPath: keyPath]
    objects.insert(object)
    t[keyPath: keyPath] = objects
  }
}

func remove<T, U>(_ keyPath: WritableKeyPath<T, Set<U>>,
                  _ object: U) -> (inout T) -> Void  {
  { t in
    var objects = t[keyPath: keyPath]
    objects.remove(object)
    t[keyPath: keyPath] = objects
  }
}

func append<T, U>(_ keyPath: WritableKeyPath<T, Set<U>>,
                  _ object: U) -> (inout T) -> Void  {
  { t in
    var objects = t[keyPath: keyPath]
    objects.insert(object)
    t[keyPath: keyPath] = objects
  }
}

func append<T, U>(_ keyPath: WritableKeyPath<T, Array<U>>,
                  _ object: U) -> (inout T) -> Void  {
  { t in
    var objects = t[keyPath: keyPath]
    objects.append(object)
    t[keyPath: keyPath] = objects
  }
}

func lookup<T, U>(keyPath: KeyPath<T, T>, _ obj: T) -> U? {
  obj[keyPath: keyPath] as? U ?? lookup(keyPath: keyPath, obj[keyPath: keyPath])
}


func lookup<T, U>(keyPath: KeyPath<T, T?>, _ obj: T) -> U? {
  if let nextObj = obj[keyPath: keyPath] {
    if let matchingObj = nextObj as? U {
      return matchingObj
    } else {
      return lookup(keyPath: keyPath, nextObj)
    }
  }
  
  return nil
}

func lookup<T, U>(_ obj: T, _ keyPath: KeyPath<T, T?>, _ lookedType: U.Type) -> U? {
  if let u = obj as? U {
    return u
  } else if let next = obj[keyPath: keyPath] {
    return lookup(next, keyPath, lookedType)
  } else {
    return nil
  }
}

func when<T>(_ condition: Bool, gen: () -> T) -> T? {
  return condition ? gen() : nil
}

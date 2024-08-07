//
//  Stack.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 14.12.2020.
//

import Foundation

final class Stack<T> {
  
  private(set) var elements = [T]()
  private let capacity: Int
  
  init(capacity: Int) {
    self.capacity = capacity
  }
  
  func append(_ element: T) {
    elements.append(element)
    if elements.count > capacity {
      elements.removeFirst()
    }
  }
  
  func pop() -> T? {
    elements.isEmpty ? nil : elements.removeLast()
  }
  
  func clear() {
    elements = []
  }
  
  func popToFirst() -> T? {
    elements = Array(elements.prefix(1))
    return elements.first
  }
  
}

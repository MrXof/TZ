//
//  Array+Revolving.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import Foundation

extension Array {
  
  func revolvingForward(times: Int) -> [Element] {
    var result = self
    for _ in 0..<times {
      result.insert(result.removeLast(), at: 0)
    }
    return result
  }
  
  func revolvingBackwards(times: Int) -> [Element] {
    var result = self
    for _ in 0..<times {
      result.insert(result.removeFirst(), at: self.count - 1)
    }
    return result
  }
  
  mutating func revolveForward(times: Int) {
    self = revolvingForward(times: times)
  }
  
  mutating func revolveBackwards(times: Int) {
    self = revolvingBackwards(times: times)
  }
  
}

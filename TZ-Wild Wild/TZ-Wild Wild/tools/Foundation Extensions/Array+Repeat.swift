//
//  Array+Repeat.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 17.02.2021.
//

import Foundation

func times<T>(_ times: Int, _ gen: () -> T) -> Array<T> {
  var result = [T]()
  for _ in 0..<times {
    result.append(gen())
  }
  return result
}

extension Array {
  
  func interlaced(_ gen: () -> Element) -> [Element] {
    var result = [Element]()
    enumerated().forEach { index, element in
      result.append(element)
      if index < count - 1 {
        result.append(gen())        
      }
    }
    return result
  }
  
}

//
//  Array+Pairs.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 24.12.2020.
//

import Foundation

extension Array {
  
  func makePairs() -> [(Element, Element)] {
    guard count >= 2 else { return [] }
    
    var result = [(Element, Element)]()
    for i in 0..<count - 1 {
      result.append((self[i], self[i + 1]))
    }
    return result
  }
  
}

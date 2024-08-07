//
//  Array+SafeAccess.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import Foundation

extension Array {
  
  var lastIndex: Int { count - 1 }
  
  func safeIndexAfter(_ index: Int) -> Int? {
    guard index < lastIndex else { return nil }
    return index + 1
  }
  
  func safeIndexBefore(_ index: Int) -> Int? {
    guard index > 0 else { return nil }
    return index - 1
  }
  
  
}

extension Array where Element: Equatable {
  
  func elementAfter(_ element: Element) -> Element? {
    guard
      let index = firstIndex(of: element),
      let nextIndex = safeIndexAfter(index)
    else { return nil }
    
    return self[nextIndex]
  }
  
  func elementBefore(_ element: Element) -> Element? {
    guard let index = firstIndex(of: element), let previousIndex = safeIndexBefore(index)
    else { return nil }
    
    return self[previousIndex]
  }
  
}

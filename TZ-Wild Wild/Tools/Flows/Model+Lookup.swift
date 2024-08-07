//
//  Model+Lookup.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 20.02.2021.
//

import Foundation

extension Module {
  
  var root: Module {
    return parent?.root ?? self
  }
  
  func firstPredecessor(matching condition: (Module) -> Bool) -> Module? {
    return condition(self) ? self : parent?.firstPredecessor(matching: condition)
  }
  
  func firstPredecessor<T>(ofType type: T.Type) -> T? {
    return firstPredecessor { $0 is T } as? T
  }
  
  func parentChain() -> [Module] {
    return [self] + (parent?.parentChain() ?? [])
  }
  
}

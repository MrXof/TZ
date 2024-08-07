//
//  PredicateSet.swift
//  InGreenient
//
//  Created by Oleksandr Bielov on 19/03/2024.
//

import Foundation

struct PredicateSet<T> {
  
  let predicate: (T) -> Bool
  
  func contains(_ element: T) -> Bool {
    predicate(element)
  }
  
}

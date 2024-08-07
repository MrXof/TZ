//
//  Mutate.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import Foundation

extension Array {
    mutating func mutate(at index: Int, f: (Element) -> Element) {
        self[index] = f(self[index])
    }
}

@discardableResult
func mutate<T, U>(_ object: T, _ keyPath: WritableKeyPath<T, U>, _ modifier: (U) -> U) -> T {
  var mutableObject = object
  mutableObject[keyPath: keyPath] = modifier(object[keyPath: keyPath])
  return mutableObject
}

@discardableResult
func mutate<T, U>(_ object: T, _ keyPath: WritableKeyPath<T, U>, _ newValue: U) -> T {
  var mutableObject = object
  mutableObject[keyPath: keyPath] = newValue
  return mutableObject
}

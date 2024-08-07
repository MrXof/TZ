//
//  Array+Split.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import Foundation

public extension Array {
  
  func split(_ f: (Element) -> Bool) -> ([Element], [Element]) {
    var passing = [Element]()
    var notPassing = [Element]()
    forEach {
      if f($0) {
        passing.append($0)
      } else {
        notPassing.append($0)
      }
    }
    return (passing, notPassing)
  }
  
  
  func extend<U>(_ f: (Element) -> U) -> [(Element, U)] {
    zip(self, map(f)).compactMap(id)
  }
  
  func group<T>(by criteria: (Element) -> T,
                sortCriteria: (Element, Element) throws -> Bool) -> [T: [Element]] where T: Hashable {
    var dictionary = [T: [Element]]()
    
    forEach { element in
      let key = criteria(element)
      var array = dictionary[key] ?? []
      array.append(element)
      dictionary[key] = array
    }
    
    dictionary.keys.forEach {
      dictionary[$0] = try? dictionary[$0]?.sorted(by: sortCriteria)
    }
    
    return dictionary
  }
  
}

extension Collection {
  
  func toGroups(_ splitter: (Element) -> Bool) -> [[Element]] {
    guard !isEmpty else { return [] }
    var result: [[Element]] = []
    var currentCluster = [Element]()
    var flag = splitter(first!)
    self.forEach {
      if splitter($0) == flag {
        currentCluster.append($0)
      } else {
        flag = splitter($0)
        result.append(currentCluster)
        currentCluster = [$0]
      }
    }
    result.append(currentCluster)
    
    return result
  }
  
}

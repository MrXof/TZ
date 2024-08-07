//
//  Array+Duplicates.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 24.02.2021.
//

import Foundation

extension Array where Element: Hashable {
  func uniqued() -> [Element] {
    var seen = Set<Element>()
    return filter { seen.insert($0).inserted }
  }
}

extension Array where Element: Hashable {
  
  func makeSet() -> Set<Element> {
    Set(self)
  }
  
}

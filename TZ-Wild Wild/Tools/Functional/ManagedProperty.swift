//
//  ManagedProperty.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 15.04.2021.
//

import Foundation

struct ManagedProperty<T> {
  
  var get: () -> T
  var set: (T) -> ()
  
}

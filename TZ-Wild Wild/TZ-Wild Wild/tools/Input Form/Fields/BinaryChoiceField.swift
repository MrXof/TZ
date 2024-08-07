//
//  BinaryChoiceField.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 23.04.2021.
//

import Foundation

final class BinaryChoiceField: InputField {
  
  let isSelected = Observable(false)
  var title = ""
  
  func toggle() {
    isSelected.value = !isSelected.value
  }
  
}

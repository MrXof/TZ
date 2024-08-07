//
//  ActionField.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 16.02.2021.
//

import Foundation

final class ActionField: InputField {
  
  var actionTitle = ""
  var action: (() -> Void)?
  var disabledAction: (() -> Void)?
  let isEnabled = Observable(true)
  
  func invokeActionAccordingToState() {
    isEnabled.value ? action?() : disabledAction?()
  }
  
}

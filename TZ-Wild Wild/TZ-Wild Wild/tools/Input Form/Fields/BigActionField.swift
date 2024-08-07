//
//  BigActionField.swift
//  unlonely-ios
//
//  Created by Andrii Sokur on 25.03.2022.
//

import Foundation

final class BigActionField: InputField {
  
  var actionTitle = ""
  var action: (() -> Void)?
  var disabledAction: (() -> Void)?
  let isEnabled = Observable(true)
  
  func invokeActionAccordingToState() {
    isEnabled.value ? action?() : disabledAction?()
  }
  
}

//
//  LongTextInputField.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 22.04.2021.
//

import UIKit

final class LongTextInputField: InputField {
  
  var title = ""
  var placeholder = ""
  let text = Observable("")
  var keyboardType: UIKeyboardType = .default
  var autocorrectionType: UITextAutocorrectionType = .default
  var autocapitalizationType: UITextAutocapitalizationType = .sentences
  
  var shouldBeginSendingValidationErrors: ((String) -> Bool) = { _ in false }

  var validator: Validator<String> = .alwaysValid() {
    didSet {
      updateValidity()
    }
  }
  
  private var allowsValidityStateNotification = false {
    didSet {
      updateValidity()
    }
  }
  
  override init() {
    super.init()
    
    canReceiveFocus = true
    
    text.observe { [weak self] text in
      guard let self = self else { return }
      if self.shouldBeginSendingValidationErrors(text) {
        self.allowsValidityStateNotification = true
      }
      self.updateValidity()
    }
  }
  
  func commitEditing() {
    allowsValidityStateNotification = true
  }
  
  func updateValidity() {
    switch self.validator.check(text.value) {
    case .valid(_): self.isValid.value = true
      self.validationErrorMessages.value = []
    case .notValid(let errors):
      self.isValid.value = false
      if allowsValidityStateNotification  {
        self.validationErrorMessages.value = Array(errors.map(get(\.text)).prefix(1))
      }
    }
  }
  
}

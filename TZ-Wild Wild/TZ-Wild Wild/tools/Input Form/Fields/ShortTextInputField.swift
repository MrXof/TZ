//
//  ShortTextInputField.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 15.02.2021.
//

import UIKit

final class ShortTextInputField: InputField {
  
  var title = ""
  var placeholder = ""
  let text = Observable("")
  let isEditable = Observable(true)
  var keyboardType: UIKeyboardType = .default
  var autocorrectionType: UITextAutocorrectionType = .default
  var autoPrefix: String?
  var autocapitalizationType: UITextAutocapitalizationType = .sentences
  var isSecureTextEntry: Bool = false
  
  var shouldBeginSendingValidationErrors: ((String) -> Bool) = { _ in false }
  
  let fullText = Observable("")

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
      self.fullText.value = [self.autoPrefix, text]
        .compactMap(id)
        .joined()
      if self.shouldBeginSendingValidationErrors(text) {
        self.allowsValidityStateNotification = true
      }
      self.updateValidity()
    }
    
    isEditable.observe { [weak self] in
      self?.canReceiveFocus = $0
    }
  }
  
  func commitEditing() {
    allowsValidityStateNotification = true
  }
  
  func updateValidity() {
    switch self.validator.check(text.value) {
    case .valid(_):
      self.isValid.value = true
      self.validationErrorMessages.value = []
    case .notValid(let errors):
      self.isValid.value = false
      if allowsValidityStateNotification  {
        self.validationErrorMessages.value = Array(errors.map(get(\.text)).prefix(1))
      }
    }
  }
  
}

//
//  InputField.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 18.06.2021.
//

import Foundation

class InputField: Hashable, Equatable {
  
  enum ReturnKeyType {
    case next, done, `default`
  }

  let uid = UUID()
  
  let returnKeyType = Observable<ReturnKeyType>(.next)
  var canReceiveFocus = false

  let validationErrorMessages = Observable([String]())
  let isValid = Observable(true)
  let didReceiveFocus = Pipe<Void>()
  let didResignFocus = Pipe<Void>()
  
  func resignFocus() {
    didResignFocus.send(())
  }
  
  func receiveFocus() {
    didReceiveFocus.send(())
  }
  
  func hash(into hasher: inout Hasher) {
    uid.hash(into: &hasher)
  }
  
  static func ==(lhs: InputField, rhs: InputField) -> Bool {
    lhs.uid == rhs.uid
  }
  
}

//
//  PlaceholderTextView.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 23.12.2020.
//

import UIKit

class PlaceholderTextView: ZeroInsetTextView {
  
  var placeholderAttributes: [NSAttributedString.Key : Any] = [:]
  var normalAttributes: [NSAttributedString.Key : Any] = [:]
  
  override var text: String! {
    didSet {
      if text != placeholder {
        typingAttributes = normalAttributes
      } else {
        attributedText = NSAttributedString(string: text,
                                            attributes: placeholderAttributes)
      }
    }
  }
  
  var placeholder: String = "" {
    didSet {
      if !isFirstResponder && (text.isEmpty || text == oldValue) {
        typingAttributes = placeholderAttributes
      }
      if text.isEmpty { text = placeholder }
    }
  }
  
  var rawValue: String {
    text == placeholder ? "" : text
  }
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    
    if text.isEmpty { text = placeholder }
  }
  
  override func becomeFirstResponder() -> Bool {
    if text == placeholder { text = "" }
    
    return super.becomeFirstResponder()
  }
  
  override func resignFirstResponder() -> Bool {
    if text.isEmpty { text = placeholder }
    
    return super.resignFirstResponder()
  }
  
}

//
//  LongTextInputCell.swift
//  InGreenient
//
//  Created by Andrii Sokur on 15.06.2022.
//

import UIKit
import HandyText

final class LongTextInputCell: UICollectionViewCell, InputFieldDisplaying {
  
  private var field: LongTextInputField?
  private var textView = PlaceholderTextView()
  private var focusToken: Subscription?
  private var textToken: Subscription?
  private var editingEnabledToken: Subscription?
  private var returnKeyToken: Subscription?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    returnKeyToken?.dispose()
    returnKeyToken = nil
    focusToken?.dispose()
    focusToken = nil
    field = nil
    textToken?.dispose()
    textToken = nil
    editingEnabledToken?.dispose()
    editingEnabledToken = nil
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  func display(_ field: InputField) {
    guard let field = field as? LongTextInputField else { return }
    
    self.field = field
    
    focusToken = field.didReceiveFocus.observe { [weak self] in
      guard let textField = self?.textView else { return }
      _ = textField.becomeFirstResponder()
    }.owned(by: self)
        
    returnKeyToken = field.returnKeyType.observe { [weak self, weak field] in
      guard let self = self, let field = field else { return }
      switch $0 {
      case .next: self.textView.returnKeyType = .next
      case .done: self.textView.returnKeyType = .done
      case .default: self.textView.returnKeyType = .default
      }
      let actionStyle: InputAccessoryView.ActionStyle = $0 == .next ? .next : .done
      if self.isAccessoryViewRequired(for: field.keyboardType) {
        self.textView.inputAccessoryView = InputAccessoryView(actionStyle: actionStyle) { [weak self] in
          self?.field?.resignFocus()
        }
      }
    }.owned(by: self)
        
    textToken = field.text.observe { [weak self] in
      self?.textView.text = $0
    }.owned(by: self)
    
//    editingEnabledToken = field.isEditable.observe { [weak self] in
//      self?.textView.isUserInteractionEnabled = $0
//      self?.textView.alpha = $0 ? 1.0 : 0.5
//    }.owned(by: self)
    
    with(textView) {
      $0.backgroundColor = .clear
      $0.autocapitalizationType = field.autocapitalizationType
      $0.autocorrectionType = field.autocorrectionType
      $0.keyboardType = field.keyboardType
      $0.normalAttributes = TextStyle.h3.foregroundColor(.spectra).textAttributes
      $0.placeholderAttributes = TextStyle.h3.foregroundColor(.spectra).opacity(0.5).textAttributes
      $0.placeholder = field.placeholder
    }
  }
  
}

private extension LongTextInputCell {
  
  func setup() {
    contentView.backgroundColor = .pampas
    contentView.clipsToBounds = true
    
    textView
      .then {
        $0.constrainHeight(to: 106.0)
        $0.delegate = self
      }
      .add(to: contentView)
      .pinToSuperview(leading: 20.0, trailing: 20.0, top: 20.0, bottom: 20.0)
    
    with(contentView.layer) {
      $0.cornerRadius = 11.0
      $0.cornerCurve = .continuous
      $0.borderWidth = 1.0
      $0.borderColor = UIColor.alto.cgColor
    }
  }
  
  func isAccessoryViewRequired(for keyboardType: UIKeyboardType) -> Bool {
    switch keyboardType {
    case .numbersAndPunctuation, .numberPad, .phonePad, .decimalPad: return true
    default: return false
    }
  }
  
}

extension LongTextInputCell: HeightCalculating {}

extension LongTextInputCell: UITextViewDelegate {
  
  func textViewDidEndEditing(_ textView: UITextView) {
    field?.commitEditing()
  }
  
  func textViewDidChange(_ textView: UITextView) {
    field?.text.value = textView.text ?? ""
  }

//  func textFieldDidEndEditing(_ textField: UITextField) {
//    field?.commitEditing()
//  }
  
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    field?.resignFocus()
//    return true
//  }

}


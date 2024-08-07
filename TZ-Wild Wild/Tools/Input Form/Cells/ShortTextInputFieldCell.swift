//
//  ShortTextInputFieldCell.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 15.02.2021.
//

import UIKit
import HandyText

final class ShortTextInputFieldCell: UICollectionViewCell, InputFieldDisplaying {
  
  private var field: ShortTextInputField?
  
  private var textField = UITextField()
  
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
    guard let field = field as? ShortTextInputField else { return }
    
    self.field = field
    
    focusToken = field.didReceiveFocus.observe { [weak self] in
      guard let textField = self?.textField else { return }
      _ = textField.becomeFirstResponder()
    }.owned(by: self)
        
    returnKeyToken = field.returnKeyType.observe { [weak self, weak field] in
      guard let self = self, let field = field else { return }
      switch $0 {
      case .next: self.textField.returnKeyType = .next
      case .done: self.textField.returnKeyType = .done
      case .default: self.textField.returnKeyType = .default
      }
      let actionStyle: InputAccessoryView.ActionStyle = $0 == .next ? .next : .done
      if self.isAccessoryViewRequired(for: field.keyboardType) {
        self.textField.inputAccessoryView = InputAccessoryView(actionStyle: actionStyle) { [weak self] in
          self?.field?.resignFocus()
        }
      }
    }.owned(by: self)
        
    textToken = field.text.observe { [weak self] in
      self?.textField.text = $0
    }.owned(by: self)
    
    editingEnabledToken = field.isEditable.observe { [weak self] in
      self?.textField.isUserInteractionEnabled = $0
      self?.textField.alpha = $0 ? 1.0 : 0.5
    }.owned(by: self)
    
    with(textField) {
      $0.autocapitalizationType = field.autocapitalizationType
      $0.autocorrectionType = field.autocorrectionType
      $0.keyboardType = field.keyboardType
      $0.placeholder = field.placeholder
      $0.applyAttributes(from: .h3.foregroundColor(.spectra))
      $0.attributedPlaceholder = field.placeholder.withStyle(.h3.foregroundColor(.spectra).opacity(0.5))
      $0.isSecureTextEntry = field.isSecureTextEntry
      
      if let prefix = field.autoPrefix {
        $0.leftView = with(UILabel()) {
          $0.text = prefix
          $0.textColor = .white
        }.wrappedWithMargins(trailing: 3.0)
      } else {
        $0.leftView = nil
      }
    }
  }
  
}

private extension ShortTextInputFieldCell {
  
  func setup() {
    contentView.backgroundColor = .pampas
    contentView.clipsToBounds = true
    
    with(textField) {
      $0.leftView = UIView.spacer(w: 18.0)
      $0.leftViewMode = .always
      $0.constrainHeight(to: 54.0)
      $0.delegate = self
      $0.addTarget(self,
                   action: #selector(textFieldTextDidChange),
                   for: .editingChanged)
      
    }.add(to: contentView)
    .pinToSuperview(leading: 20.0, trailing: 20.0, top: 0.0, bottom: 0.0)
    
    with(contentView.layer) {
      $0.cornerRadius = 11.0
      $0.cornerCurve = .continuous
      $0.borderWidth = 1.0
      $0.borderColor = UIColor.alto.cgColor
    }
  }
  
  @objc
  func textFieldTextDidChange(_ textField: UITextField) {
    field?.text.value = textField.text ?? ""
  }
  
  func isAccessoryViewRequired(for keyboardType: UIKeyboardType) -> Bool {
    switch keyboardType {
    case .numbersAndPunctuation, .numberPad, .phonePad, .decimalPad: return true
    default: return false
    }
  }
  
}

extension ShortTextInputFieldCell: HeightCalculating {}

extension ShortTextInputFieldCell: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    field?.commitEditing()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    field?.resignFocus()
    return true
  }

}

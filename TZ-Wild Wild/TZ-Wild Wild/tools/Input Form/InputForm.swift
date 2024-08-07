//
//  InputForm.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 18.06.2021.
//

import Foundation

struct Group {
  let location: Int
  let length: Int
  
  func contains(_ index: Int) -> Bool {
    (location..<(location + length)).contains(index)
  }
}

class InputForm: Module {
  
  let didUpdateHiddenFields = Pipe<Void>()
  let needsErrorMessageUpdate = Pipe<IndexPath>()
  let isValid = Observable(false)
  let didEndEditing = Pipe<Void>()
  let didReceiveFocusAtIndex = Pipe<Int>()
  
  var changeApplicators = [() -> Void]()
  
  var hiddenFields = Set<InputField>() {
    didSet {
      didUpdateHiddenFields.send(())
      subscribeForFocusUpdates()
    }
  }
  
  private var focusSubscriptions = [Subscription]()
  
  var fields: [InputField]! {
    didSet {
      subscribeForFocusUpdates()
      subscribeForValidityState()
      subscribeForErrorMessagesUpdates()
    }
  }
  
  override func didMoveToParent() {
    super.didMoveToParent()
    
    setup()
  }
  
  func setup() {
    fatalError() // overridden by subclasses
  }
  
  func field(at indexPath: IndexPath) -> InputField {
    fields[indexPath.item]
  }
  
  func indexPath(for field: InputField) -> IndexPath {
    .init(item: fields.firstIndex(of: field)!, section: 0)
  }
  
  func applyChanges() {
    changeApplicators.forEach { $0() }
  }
  
  func validationErrorMessages(at indexPath: IndexPath) -> [String] {
    field(at: indexPath).validationErrorMessages.value
  }
  
  func clusters() -> [Group] {
    []
  }
  
  func subsections() -> [Group] {
    []
  }
  
  var lastInputKeyType: InputField.ReturnKeyType {
    .done
  }
  
  func updateValidityState() {
    isValid.value = fields
      .map(get(\.isValid.value))
      .reduce(true) { $0 && $1 }
  }
  
}

private extension InputForm {
  
  func subscribeForFocusUpdates() {
    guard fields != nil else { return }
    
    let focusSensitiveFields = fields.filter { $0.canReceiveFocus && !hiddenFields.contains($0) }
    
    focusSubscriptions.forEach { $0.dispose() }
    focusSubscriptions = []
    
    if let last = focusSensitiveFields.last {
      focusSubscriptions.append(last.didResignFocus.observe { [weak self] in
        self?.didEndEditing.send(())
      }.owned(by: self))
    }
    
    focusSensitiveFields.forEach { field in
      let f = field
      focusSubscriptions.append(field.didResignFocus.observe { [weak self, weak f] in
        guard let self = self, let field = f else { return }
        self.findNextFocusReceiver(after: field)?.receiveFocus()
      }.owned(by: self))
    }
    
    if let last = focusSensitiveFields.last {
      focusSubscriptions.append(last.didResignFocus.observe { [weak self] in
        self?.didEndEditing.send(())
      }.owned(by: self))
    }
    
    focusSensitiveFields.enumerated().forEach { index, field in
      let absoluteIndex = fields.firstIndex(of: field)!
      focusSubscriptions.append(field.didReceiveFocus.observe { [weak self] in
        self?.didReceiveFocusAtIndex.send(absoluteIndex)
      }.owned(by: self))
    }
    
    focusSensitiveFields.forEach { $0.returnKeyType.value = .next }
    focusSensitiveFields.last?.returnKeyType.value = lastInputKeyType
  }
  
  func findNextFocusReceiver(after field: InputField) -> InputField? {
    fields
      .filter { $0.canReceiveFocus && !hiddenFields.contains($0) }
      .elementAfter(field)
  }

  func subscribeForValidityState() {
    fields.forEach {
      $0.isValid.observe { [weak self] _ in
        self?.updateValidityState()
      }.owned(by: self)
    }
  }
  
  func subscribeForErrorMessagesUpdates() {
    fields.forEach {
      let field = $0
      $0.validationErrorMessages.observe { [weak self, weak field] _ in
        guard let self = self, let field = field else { return }
        self.needsErrorMessageUpdate.send(self.indexPath(for: field))
      }.owned(by: self)
    }
  }
  
}

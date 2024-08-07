//
//  AutoHeightTextView.swift
//  interview-ai-ios
//
//  Created by Oleksandr Bielov on 06/09/2023.
//

import UIKit

extension UITextView: HeightCalculating { }

final class AutoHeightTextView: PlaceholderTextView, UITextViewDelegate {
  
  var minHeight: CGFloat = 56.0 {
    didSet {
      resizeView()
    }
  }
  var maxHeight: CGFloat = 200.0 {
    didSet {
      resizeView()
    }
  }
  
  private var _delegate: UITextViewDelegate?
  override var delegate: UITextViewDelegate? {
    get {
      _delegate
    }
    set {
      fatalError()
    }
  }
  
  override var normalAttributes: [NSAttributedString.Key : Any] {
    didSet {
      viewToCalculate.normalAttributes = normalAttributes
    }
  }
  
  override var placeholderAttributes: [NSAttributedString.Key : Any] {
    didSet {
      viewToCalculate.placeholderAttributes = placeholderAttributes
    }
  }
  
  override var placeholder: String {
    didSet {
      viewToCalculate.placeholder = placeholder
    }
  }
  
  override var contentInset: UIEdgeInsets {
    didSet {
      viewToCalculate.contentInset = contentInset
    }
  }
  
  override var text: String! {
    didSet {
      resizeView()
    }
  }
  
  let textValue = Observable<String>("")
  private let viewToCalculate = PlaceholderTextView()
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    
    self._delegate = self
    self.constrainHeight(to: minHeight)
    textValue.observe { [weak self] in
      self?.text = $0
    }.owned(by: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  func textViewDidChange(_ textView: UITextView) {
    textValue.value = textView.text ?? ""
  }
  
  private func resizeView() {
    viewToCalculate.text = text ?? ""
    let prefferedHeight = viewToCalculate.height(atWidth: width) + contentInset.top
    let newHeight = max(min(prefferedHeight, maxHeight), minHeight)
//    print("preffered height: \(prefferedHeight); setting height: \(newHeight)")
    
    guard !self.constraints.isEmpty else { return }
    self.updateConstraints {
      $0.height.equalTo(newHeight)
    }
  }
  
}


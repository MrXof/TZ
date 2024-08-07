//
//  TypewriterEffect.swift
//  PRSPR
//
//  Created by Oleksii Chernysh on 04.11.2021.
//

import UIKit
import HandyText

final class TypewriterEffect {
  
  private let label: UILabel
  private let initialText: NSAttributedString
  private var targetText: String!
  private let style: TextStyle
  
  private var currentText: NSAttributedString {
    label.attributedText ?? .init()
  }
  
  init(label: UILabel, style: TextStyle) {
    self.label = label
    self.style = style
    initialText = label.attributedText ?? NSAttributedString(string: label.text ?? "")
  }
  
  func setAlpha(_ alpha: CGFloat, at index: Int) {
    guard index >= 0 && index < currentText.length else { return }
    let range = NSRange(location: index, length: 1)
    label.attributedText = currentText.applyStyle(style.opacity(alpha), in: range)
  }
  
  func animate(to string: String) {
    targetText = string
    hide(lastIndex: currentText.length - 1)
  }
  
  func hide(lastIndex: Int) {
    label.animate(t: 0.2) { $0.alpha = .zero }
      .whenFinished { _ in
        self.showNewText()
      }.start()
  }
  
  func showNewText() {
    label.attributedText = targetText.withStyle(style.opacity(.zero))
    show(firstIndex: 0)
    
    label.animate(t: 0.5) {
      $0.alpha = 1.0
    }.start()
  }
  
  func show(firstIndex: Int) {
    let chunkLength = max(1, currentText.length / 5)
    let durationPerChunk = 0.025 / TimeInterval(chunkLength)
    
    label.animatedTransition(duration: durationPerChunk, animations: {
      (firstIndex...firstIndex + chunkLength).forEach { characterIndex in
        self.setAlpha(0.5 / CGFloat(characterIndex - firstIndex), at: characterIndex)
      }
      (firstIndex - chunkLength...firstIndex).forEach {
        self.setAlpha(1.0, at: $0 - 1)
      }
    }) { _ in
      if firstIndex < self.currentText.length + chunkLength {
        self.show(firstIndex: firstIndex + chunkLength)
      }
    }

  }
  
}

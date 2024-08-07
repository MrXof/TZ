//
//  Array+ViewStack.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 10.02.2021.
//

import UIKit

extension Array where Element: UIView {
  
  func makeHStack(spacing: CGFloat = .zero,
                  _ decorator: ((UIStackView) -> Void)? = nil) -> UIStackView {
    makeStack(.horizontal, spacing: spacing, decorator: decorator)
  }
  
  func makeVStack(spacing: CGFloat = .zero,
                  _ decorator: ((UIStackView) -> Void)? = nil) -> UIStackView {
    makeStack(.vertical, spacing: spacing, decorator: decorator)
  }
  
  private func makeStack(_ axis: NSLayoutConstraint.Axis,
                         spacing: CGFloat,
                         decorator: ((UIStackView) -> Void)? = nil) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = axis
    stackView.spacing = spacing
    
    forEach { stackView.addArrangedSubview($0) }
    
    decorator?(stackView)
    
    return stackView
  }
  
}

extension UIView {
  
  static func spacer(h: CGFloat? = nil, w: CGFloat? = nil) -> UIView {
    with(UIView()) {
      if let h = h { $0.constrainHeight(to: h) }
      if let w = w { $0.constrainWidth(to: w) }
    }
  }
  
}

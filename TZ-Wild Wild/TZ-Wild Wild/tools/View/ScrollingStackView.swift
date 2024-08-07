//
//  ScrollingStackView.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 11.12.2020.
//

import UIKit

extension UIView {
  
  @discardableResult
  func add(to scrollingStackView: ScrollingStackView) -> Self {
    add(to: scrollingStackView.stackView)
    return self
  }
  
}

final class ScrollingStackView: UIView {
  
  var axis: NSLayoutConstraint.Axis = .vertical {
    didSet {
      stackView.axis = axis
    }
  }
  
  var showsScrollIndicator: Bool {
    get { scrollView.showsVerticalScrollIndicator }
    set { scrollView.showsVerticalScrollIndicator = newValue }
  }
  
  var contentOffset: CGPoint {
    get { scrollView.contentOffset }
    set { scrollView.contentOffset = newValue }
  }
  
  weak var delegate: UIScrollViewDelegate? {
    set { scrollView.delegate = newValue }
    get { scrollView.delegate }
  }
  
  var insets: UIEdgeInsets = .zero {
    didSet {
      stackView.snp.updateConstraints {
        $0.left.equalToSuperview().offset(insets.left)
        $0.right.equalToSuperview().offset(-insets.right)
      }
      scrollView.contentInset.top = insets.top
      scrollView.contentInset.bottom = insets.bottom
    }
  }
  
  var spacing: CGFloat {
    get { stackView.spacing }
    set { stackView.spacing = newValue }
  }
  
  var arrangedSubviews: [UIView] {
    stackView.arrangedSubviews
  }
  
  override var clipsToBounds: Bool {
    didSet {
      stackView.clipsToBounds = clipsToBounds
      scrollView.clipsToBounds = clipsToBounds
    }
  }
  
  let stackView = UIStackView()
  let scrollView = UIScrollView()
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    
    stackView.layoutIfNeeded()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  func insertArrangedSubview(_ view: UIView, before subview: UIView) {
    if let index = stackView.subviews.firstIndex(of: subview) {
      stackView.insertArrangedSubview(view, at: index)
    }
  }
  
  func insertArrangedSubview(_ view: UIView, after subview: UIView) {
    if let index = stackView.subviews.firstIndex(of: subview) {
      stackView.insertArrangedSubview(view, at: index + 1)
    }
  }
  
  func insertArrangedSubview(_ view: UIView, at index: Int) {
    stackView.insertArrangedSubview(view, at: index)
  }
  
  func index(of subview: UIView) -> Int? {
    return stackView.arrangedSubviews.firstIndex(of: subview)
  }
  
  func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
    stackView.setCustomSpacing(spacing, after: view)
  }
  
  
  func addSpace(_ l: CGFloat) {
    stackView.addSpace(l)
  }

}

private extension ScrollingStackView {
  
  func setup() {
    with(scrollView) {
      $0.alwaysBounceVertical = true
      addSubview($0)
      $0.constrainEdgesToSuperview()
    }
    
    with(stackView) {
      scrollView.addSubview($0)
      $0.constrainEdgesToSuperview()
      $0.snp.makeConstraints {
        $0.centerX.equalToSuperview()
      }
      $0.axis = .vertical
    }
  }
  
}

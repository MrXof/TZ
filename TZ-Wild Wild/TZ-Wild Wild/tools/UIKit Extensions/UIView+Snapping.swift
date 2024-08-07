//
//  UIView+Snapping.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import UIKit
import SnapKit

extension UIView {
  
  @discardableResult
  func add(to view: UIView) -> Self {    view.addSubview(self)
    return self
  }
  
  @discardableResult
  func add(to stackView: UIStackView) -> Self {
    stackView.addArrangedSubview(self)
    return self
  }
  
  @discardableResult
  func constrainEdgesToSuperview() -> Self {
    snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    return self
  }
  
  func wrappedWithMargins(leading: CGFloat = .zero,
                          trailing: CGFloat = .zero,
                          top: CGFloat = .zero,
                          bottom: CGFloat = .zero) -> UIView {
    let wrapper = UIView()
    wrapper.addSubview(self)
    
    snp.makeConstraints {
      $0.leading.equalToSuperview().offset(leading)
      $0.trailing.equalToSuperview().offset(-trailing)
      $0.top.equalToSuperview().offset(top)
      $0.bottom.equalToSuperview().offset(-bottom)
    }
    
    return wrapper
  }
  
  func wrapped(margin: CGFloat = .zero) -> UIView {
    wrappedWithMargins(leading: margin,
                       trailing: margin,
                       top: margin,
                       bottom: margin)
  }
  
  func wrapped(_ closure: (ConstraintMaker) -> Void) -> UIView {
    return UIView().then {
      return self
        .add(to: $0)
        .snp.makeConstraints(closure)
    }
  }
  
  @discardableResult
  func makeConstraints(_ closure: (ConstraintMaker) -> Void) -> Self {
    snp.makeConstraints(closure)
    return self
  }
  
  @discardableResult
  func updateConstraints(_ closure: (ConstraintMaker) -> Void) -> Self {
    snp.updateConstraints(closure)
    return self
  }
  
  @discardableResult
  func pinToSuperview(leading: CGFloat? = nil,
                      trailing: CGFloat? = nil,
                      top: CGFloat? = nil,
                      bottom: CGFloat? = nil) -> Self {
    snp.makeConstraints {
      if let leading = leading {
        $0.leading.equalToSuperview().offset(leading)
      }
      if let trailing = trailing {
        $0.trailing.equalToSuperview().offset(-trailing)
      }
      if let top = top {
        $0.top.equalToSuperview().offset(top)
      }
      if let bottom = bottom {
        $0.bottom.equalToSuperview().offset(-bottom)
      }
    }
    
    return self
  }
  
  @discardableResult
  func pinToSafeArea(leading: CGFloat? = nil,
                     trailing: CGFloat? = nil,
                     top: CGFloat? = nil,
                     bottom: CGFloat? = nil) -> Self {
    let parent = superview!
    snp.makeConstraints {
      if let leading = leading {
        $0.leading.equalTo(parent.safeAreaLayoutGuide.snp.leading).offset(leading)
      }
      if let trailing = trailing {
        $0.trailing.equalTo(parent.safeAreaLayoutGuide.snp.trailing).offset(-trailing)
      }
      if let top = top {
        $0.top.equalTo(parent.safeAreaLayoutGuide.snp.top)
          .offset(top)
      }
      if let bottom = bottom {
        $0.bottom.equalTo(parent.safeAreaLayoutGuide.snp.bottom).offset(-bottom)
      }
    }
    
    return self
  }
  
  @discardableResult
  func pinToSuperview(margins: CGFloat) -> Self {
    snp.makeConstraints {
      $0.leading.equalToSuperview().offset(margins)
      $0.trailing.equalToSuperview().offset(-margins)
      $0.top.equalToSuperview().offset(margins)
      $0.bottom.equalToSuperview().offset(-margins)
    }
    
    return self
  }
  
  @discardableResult
  func constrainWidth(to width: CGFloat) -> Self {
    snp.makeConstraints {
      $0.width.equalTo(width)
    }
    
    return self
  }
  
  @discardableResult
  func constrainHeight(to height: CGFloat) -> Self {
    snp.makeConstraints {
      $0.height.equalTo(height)
    }
    return self
  }
  
  @discardableResult
  func constrainSide(to side: CGFloat) -> Self {
    snp.makeConstraints {
      $0.width.equalTo(side)
      $0.height.equalTo(side)
    }
    return self
  }
  
  @discardableResult
  func pinCenter(to view: UIView? = nil) -> Self {
    guard let viewToPin = view ?? superview else { fatalError() }
    snp.makeConstraints {
      $0.center.equalTo(viewToPin)
    }
    return self
  }
  
  @discardableResult
  func pinCenterX(to view: UIView? = nil, offset: CGFloat = .zero) -> Self {
    guard let viewToPin = view ?? superview else { fatalError() }
    snp.makeConstraints {
      $0.centerX.equalTo(viewToPin).offset(offset)
    }
    return self
  }
  
  @discardableResult
  func pinCenterY(to view: UIView? = nil, offset: CGFloat = .zero) -> Self {
    guard let viewToPin = view ?? superview else { fatalError() }
    snp.makeConstraints {
      $0.centerY.equalTo(viewToPin).offset(offset)
    }
    return self
  }
  
  @discardableResult
  func centerXWrapped() -> UIView {
    with(UIView()) {
      $0.addSubview(self)
      pinToSuperview(top: .zero, bottom: .zero)
      pinCenterX()
    }
  }
  
  @discardableResult
  func centerYWrapped() -> UIView {
    with(UIView()) {
      $0.addSubview(self)
      pinToSuperview(leading: .zero, trailing: .zero)
      pinCenterY()
    }
  }
  
  @discardableResult
  func centerXYWrapped() -> UIView {
    with(UIView()) {
      $0.addSubview(self)
      pinCenterX()
      pinCenterY()
    }
  }
  
  @discardableResult
  func aspectRatio(_ ratio: CGFloat) -> Self {
    snp.makeConstraints {
      $0.width.equalTo(snp.height).multipliedBy(ratio)
    }
    return self
  }
  
  @discardableResult
  func constrain(_ side: KeyPath<ConstraintMaker, ConstraintMakerExtendable>,
                 to item: ConstraintItem,
                 offset: CGFloat? = nil,
                 multiplied: CGFloat? = nil) -> Self {
    self.makeConstraints {
      var constraint = $0[keyPath: side].equalTo(item)
      if let offset = offset {
        constraint = constraint.offset(offset)
      }
      if let multiplied = multiplied {
        constraint = constraint.multipliedBy(multiplied)
      }
    }
    
    return self
  }
  
}

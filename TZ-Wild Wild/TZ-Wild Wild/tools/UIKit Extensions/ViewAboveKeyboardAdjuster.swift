//
//  ViewAboveKeyboardAdjuster.swift
//  mapin-ios
//
//  Created by Oleksandr Bielov on 20/09/2023.
//

import UIKit

final class ViewAboveKeyboardAdjuster: NSObject {
  
  private let keyboardListener = KeyboardListener()
  weak var viewToMove: UIView?
  weak var scrollViewToAdjust: UIScrollView? {
    didSet {
      scrollViewBottomInset = scrollViewToAdjust?.contentInset.bottom ?? .zero
    }
  }
  var viewBottomInset: CGFloat = .zero
  
  private var scrollViewBottomInset: CGFloat = .zero
  
  override init() {
    super.init()
    
    keyboardListener.keyboardWillShow.observe { [weak self] options in
      guard let self = self else { return }
      
      self.moveViewIfNeeded(with: options.duration)
      self.adjustInsetIfNeeded()
    }.owned(by: self)
    
    keyboardListener.keyboardWillHide.observe { [weak self] options in
      guard let self = self else { return }
      
      self.viewToMove?.transform = .identity
      self.scrollViewToAdjust?.contentInset.bottom = self.scrollViewBottomInset
    }.owned(by: self)
  }
  
  func moveViewIfNeeded(with duration: TimeInterval) {
    guard let view = viewToMove else { return }
    
    view.transform = .identity
    
    let endFrame = keyboardListener.keyboardFrame
    
    let viewMinY = view.globalFrame.minY
    let viewBottomSide = viewMinY + view.height
    
    let offsetY = (viewBottomSide - endFrame.minY + viewBottomInset) * (-1)
    guard offsetY < 0 else { return }
    
    UIView.animate(withDuration: duration) { [weak view] in
      view?.transform = .init(
        translationX: .zero,
        y: offsetY)
    }
  }
  
  func adjustInsetIfNeeded() {
    guard let scrollView = scrollViewToAdjust else { return }
    
    let endFrame = keyboardListener.keyboardFrame
    
    let minY = scrollView.globalFrame.minY
    let contentHeight = endFrame.minY - (viewToMove?.height ?? .zero) - minY
    let bottomInset = scrollView.height - contentHeight
    scrollView.contentInset.bottom = bottomInset
  }
  
}

extension UIView {
  
  var globalFrame: CGRect {
    guard let window = window,
          let superview = superview
    else { return .zero }
    
    return superview.convert(frame, to: window.screen.coordinateSpace)
  }
  
}

extension UIView {
  
  private static var adjusterKey: Int = 0
  
  private var adjuster: ViewAboveKeyboardAdjuster {
    get {
      if let adjuster = objc_getAssociatedObject(self, &Self.adjusterKey) as? ViewAboveKeyboardAdjuster {
        return adjuster
      }
      let newAdjuster = ViewAboveKeyboardAdjuster()
      self.adjuster = newAdjuster
      return newAdjuster
    }
    set {
      objc_setAssociatedObject(self,
                               &Self.adjusterKey,
                               newValue,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  @discardableResult
  func adjustToKeyboard(with scrollView: UIScrollView? = nil, inset: CGFloat = .zero) -> Self {
    adjuster.viewToMove = self
    adjuster.viewBottomInset = inset
    if let scrollView = scrollView {
      adjuster.scrollViewToAdjust = scrollView
    }
    return self
  }
  
}

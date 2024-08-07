//
//  KeyboardHandlingBehavior.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 16.02.2021.
//

import UIKit

final class KeyboardHandlingBehavior: NSObject, CollectionViewBehavior {
  
  weak var collectionView: UICollectionView!
  
  private var isKeyboardShown = false
  private let keyboardListener = KeyboardListener()
  private var cachedBottomInset: CGFloat = .zero
  private var stateSwitchBuffer: CallBuffer!
  
  override init() {
    super.init()
    stateSwitchBuffer = .init(delay: 0.1, call: {})
    keyboardListener.keyboardWillShow.observe { [weak self] options in
      self?.animateKeyboardShow(options: options)
    }.owned(by: self)
    
    keyboardListener.keyboardWillHide.observe { [weak self] options in
      self?.animateKeyboardHide(options: options)
    }.owned(by: self)
  }
  
}

private extension KeyboardHandlingBehavior {
  
  func animateKeyboardShow(options: KeyboardAnimationOptions) {
    let keyboardFrame = options.frameEnd
    let collectionViewAbsoluteFrame = self.collectionView.superview?.convert(self.collectionView.frame, to: nil) ?? .zero
    let maxCollectionViewY = collectionViewAbsoluteFrame.maxY
    let screenHeight = self.collectionView.window?.frame.size.height ?? 0.0
    let distanceFromTheBottom = screenHeight - maxCollectionViewY
    
    let newInset = keyboardFrame.height - distanceFromTheBottom
    var contentInset = self.collectionView.contentInset
    if cachedBottomInset == .zero {
      cachedBottomInset = contentInset.bottom
    }
    
    var safeAreaInset = UIDevice.safeAreaInsets.bottom
    if safeAreaInset == .zero {
      safeAreaInset = 30.0
    } else {
      safeAreaInset = .zero
    }
    contentInset.bottom = newInset + safeAreaInset
    
    if collectionView.contentInset != contentInset {
      collectionView.contentInset = contentInset
      collectionView.scrollIndicatorInsets = contentInset
    }
  }
  
  func animateKeyboardHide(options: KeyboardAnimationOptions) {
    stateSwitchBuffer.scheduleCall()
    isKeyboardShown = false
    collectionView.contentInset.bottom = cachedBottomInset
    collectionView.verticalScrollIndicatorInsets.bottom = cachedBottomInset
    cachedBottomInset = .zero
  }
    
}

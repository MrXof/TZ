//
//  KeyboardListener.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 16.02.2021.
//


import UIKit

struct KeyboardAnimationOptions {
  let duration: TimeInterval
  let curve: UIView.AnimationCurve
  let frameBegin: CGRect
  let frameEnd: CGRect
}

public final class KeyboardListener {
  
  var keyboardFrame: CGRect {
    if let _keyboardFrame = _keyboardFrame {
      return _keyboardFrame
    }
    let screenSize = UIDevice.screenSize
    
    return .init(x: .zero,
                 y: screenSize.height,
                 width: screenSize.width,
                 height: 302.0 + (UIDevice.isShort ? .zero : UIDevice.safeAreaInsets.bottom))
  }
  private var _keyboardFrame: CGRect?
  let keyboardWillShow = Pipe<KeyboardAnimationOptions>()
  let keyboardDidShow = Pipe<CGRect>()
  let keyboardWillHide = Pipe<KeyboardAnimationOptions>()
  let keyboardDidHide = Pipe<CGRect>()
  let keyboardDidChangeFrame = Pipe<CGRect>()
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: self)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: self)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: self)
  }
  
  public init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardDidShow),
      name: UIResponder.keyboardDidShowNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardDidHide),
      name: UIResponder.keyboardDidHideNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardDidChangeFrame),
      name: UIResponder.keyboardDidChangeFrameNotification,
      object: nil)
  }
  
}

private extension KeyboardListener {
  
  @objc
  func handleKeyboardWillShow(notification: Notification) {
    if let options = animationOptions(from: notification) {
      _keyboardFrame = options.frameEnd
      keyboardWillShow.send(options)
    }
  }
  
  @objc func handleKeyboardDidShow(notification: Notification) {
    if let endFrame = endFrame(from: notification) {
      keyboardDidShow.send(endFrame)
    }
  }
  
  @objc func handleKeyboardWillHide(notification: Notification) {
    if let options = animationOptions(from: notification) {
      _keyboardFrame = options.frameEnd
      keyboardWillHide.send(options)
    }
  }
  
  @objc func handleKeyboardDidHide(notification: Notification) {
    if let endFrame = endFrame(from: notification) {
      keyboardDidHide.send(endFrame)
    }
  }
  
  @objc func handleKeyboardDidChangeFrame(notification: Notification) {
    if let endFrame = endFrame(from: notification) {
      _keyboardFrame = endFrame
      keyboardDidChangeFrame.send(endFrame)
    }
  }
  
  func animationOptions(from notification: Notification) -> KeyboardAnimationOptions? {
    guard
      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
      let curveRawValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
      let curve = UIView.AnimationCurve(rawValue: curveRawValue),
      let frameBegin = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
      let frameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    else {
      return nil
    }
    
    return KeyboardAnimationOptions(duration: duration,
                                    curve: curve,
                                    frameBegin: frameBegin,
                                    frameEnd: frameEnd)
  }
  
  func endFrame(from notification: Notification) -> CGRect? {
    return notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
  }
  
}

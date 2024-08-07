//
//  UIDevice+Insets.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 18.12.2020.
//

import UIKit

extension UIDevice {
  
  static var mainWindow: UIWindow? {
    guard
      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let sceneDelegate = windowScene.delegate as? SceneDelegate
    else { return nil }
    
    return sceneDelegate.window
  }
  
  static var screenSize: CGSize {
    mainWindow?.size ?? .zero
  }
  
  static var safeAreaInsets: UIEdgeInsets {
    guard
      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let sceneDelegate = windowScene.delegate as? SceneDelegate,
      let window = sceneDelegate.window
    else { return .zero }
    
    return window.safeAreaInsets
  }
  
  static var hasSafeArea: Bool {
    safeAreaInsets.bottom != .zero
  }
  
  static var isShort: Bool {
    UIScreen.main.bounds.height < 700.0
  }
  
  static var lessThan11Pro: Bool {
    UIScreen.main.bounds.height < 812.0
  }
  
  static var smallerThan11: Bool {
    UIScreen.main.bounds.height < 896.0
  }
  
  static var isOldFormat: Bool {
    !hasSafeArea
  }
  
}

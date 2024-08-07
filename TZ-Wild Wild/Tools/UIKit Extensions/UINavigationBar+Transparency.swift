//
//  UINavigationBar+Transparency.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 01.06.2021.
//

import UIKit

extension UINavigationBar {
  
  func makeTransparent() {
    setColor(.clear)
    isTranslucent = true
    setBackgroundImage(UIImage(), for: .default)
  }

  func setColor(_ color: UIColor) {
    shadowImage = UIImage()
    isTranslucent = true
    backgroundColor = color
    barTintColor = color
    
    //TODO: (sokur) Refactoring (under a protocol?)
//    flatten(self, get(\.subviews))
//      .filter { !($0 is NavigationButtonBackgroundView) }
//      .forEach { $0.backgroundColor = .clear }
  }
  
}

//
//  CardViewStyle.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 22.03.2021.
//

import UIKit

extension UIStyle {
  
  static var card: ViewStyle<UIView> {
    roundCorners(12.0) <>
    .init {
      $0.backgroundColor = .white
    }
  }
  
  static var bordered: ViewStyle<UIView> {
    .init {
      $0.layer.borderWidth = 1.0
      $0.layer.borderColor = UIColor.hex("CCD1D5").cgColor
    }
  }
  
  static var glow: ViewStyle<UIView> {
    .init {
      with($0.layer) {
        $0.masksToBounds = false
        $0.shadowColor = UIColor.hex("22ABBE").cgColor
        $0.shadowRadius = 10.0
        $0.shadowOpacity = 0.55
        $0.shadowOffset = .init(width: .zero, height: 8.0)
      }
    }
  }
  
}

//
//  UIColor+RGB.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import UIKit

extension UIColor {
  
  static func gray(_ value: Int) -> UIColor {
    rgb(value, value, value)
  }
  
  static func rgb(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
    rgba(r, g, b, 1.0)
  }
  
  static func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat) -> UIColor {
    let denominator: CGFloat = 255.0
    
    return .init(red: CGFloat(r) / denominator,
                 green: CGFloat(g) / denominator,
                 blue: CGFloat(b) / denominator,
                 alpha: a)
  }
  
}


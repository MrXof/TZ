//
//  UIView+Snapshot.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import UIKit

extension UIView {
  
  func snapshot(opaque: Bool = false) -> UIImage? {
    defer { UIGraphicsEndImageContext() }
    
    UIGraphicsBeginImageContextWithOptions(frame.size, opaque, .zero)
    if let context = UIGraphicsGetCurrentContext() {
      layer.render(in: context)
    }
    
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
}

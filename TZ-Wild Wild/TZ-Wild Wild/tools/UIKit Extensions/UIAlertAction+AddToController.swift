//
//  UIAlertAction+AddToController.swift
//  interview-ai-ios
//
//  Created by Oleksandr Bielov on 25/09/2023.
//

import UIKit

extension UIAlertAction {
  
  @discardableResult
  func add(to controller: UIAlertController) -> Self {
    controller.addAction(self)
    return self
  }
  
}

//
//  UIAlertAction+Default.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 15.12.2020.
//

import UIKit

extension UIAlertAction {
  
  static func ok(_ action: (() -> Void)? = nil) -> UIAlertAction {
    UIAlertAction(title: "general.action.ok".localized,
                  style: .default) { _ in
      action?()
    }
  }
  
  static func cancel(_ action: (() -> Void)? = nil) -> UIAlertAction {
    UIAlertAction(title: "general.action.cancel".localized,
                  style: .cancel) { _ in
      action?()
    }
  }
  
}

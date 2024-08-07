//
//  UIViewController+Toasts.swift
//  PRSPR
//
//  Created by Oleksii Chernysh on 27.10.2021.
//

import UIKit
import Toast_Swift

extension UIViewController {
  
  func childToShowToast() -> UIViewController {
    presentedViewController?.childToShowToast() ?? self
  }
  
  func makeErrorToast(_ message: String, action: (() -> Void)? = nil) {
    var style = ToastStyle()
    style.messageColor = .hex("D96186")
    style.titleColor = .red

     view.makeToast(message, style: style) { tapped in
      if tapped {
        action?()
      }
    }
  }
  
}

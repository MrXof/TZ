//
//  UIViewController+Transition.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 14.12.2020.
//

import UIKit

extension UINavigationController {
  
  func push(_ viewController: UIViewController) {
    pushViewController(viewController, animated: true)
  }
  
  func pop() {
    popViewController(animated: true)
  }
  
}

extension UIViewController {

  func present(_ otherController: UIViewController) {
    self.present(otherController, animated: true)
  }

  func dismiss() {
    dismiss(animated: true)
  }
}


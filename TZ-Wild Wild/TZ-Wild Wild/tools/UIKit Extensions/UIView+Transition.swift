//
//  UIView+Transition.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 15.12.2020.
//

import UIKit

extension UIView {
  
  func animatedTransition(duration: TimeInterval = 0.15,
                          animations: @escaping () -> Void,
                          completion: ((Bool) -> Void)? = nil) {
    UIView.transition(
      with: self,
      duration: duration,
      options: .transitionCrossDissolve,
      animations: animations,
      completion: completion
    )
  }
  
}

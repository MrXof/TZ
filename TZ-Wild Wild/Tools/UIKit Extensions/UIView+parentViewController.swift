//
//  UIView+parentViewController.swift
//  InGreenient
//
//  Created by Oleksandr Bielov on 08/03/2024.
//

import UIKit

extension UIResponder {
  
  public var parentViewController: UIViewController? {
    return next as? UIViewController ?? next?.parentViewController
  }
  
}

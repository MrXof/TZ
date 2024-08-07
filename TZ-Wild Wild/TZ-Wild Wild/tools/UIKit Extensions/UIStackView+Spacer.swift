//
//  UIStackView+Spacer.swift
//  OneCourt
//
//  Created by Oleksii Chernysh on 02.07.2021.
//

import UIKit

extension UIStackView {
  
  func addSpace(_ l: CGFloat) {
    let spacer: UIView
    
    switch axis {
    case .horizontal: spacer = .spacer(w: l)
    case .vertical: spacer = .spacer(h: l)
    @unknown default: spacer = UIView()
    }
    
    addArrangedSubview(spacer)
  }
  
}

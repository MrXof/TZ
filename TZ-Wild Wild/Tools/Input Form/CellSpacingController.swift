//
//  CellSpacingController.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 23.04.2021.
//

import CoreGraphics

protocol CellSpacingProviding {
  
  var defaultSpacing: CGFloat { get set }
  
  func spacingBetween(_ topId: String, and bottomId: String) -> CGFloat
  
}

class CellSpacingController: CellSpacingProviding {
  
  var defaultSpacing: CGFloat = 15.0
  
  func spacingBetween(_ topId: String, and bottomId: String) -> CGFloat {
    defaultSpacing
  }
  
}

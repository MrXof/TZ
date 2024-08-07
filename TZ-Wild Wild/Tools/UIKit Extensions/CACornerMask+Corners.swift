//
//  CACornerMask+Corners.swift
//  Sessile
//
//  Created by Oleksandr Bielov on 03.11.2022.
//

import UIKit

extension CACornerMask {

  static var leftBottom: CACornerMask = .layerMinXMaxYCorner
  static var rightBottom: CACornerMask = .layerMaxXMaxYCorner
  static var leftTop: CACornerMask = .layerMinXMinYCorner
  static var rightTop: CACornerMask = .layerMaxXMinYCorner
  
  static var bottomCorners: CACornerMask = [.leftBottom, .rightBottom]
  static var leftCorners: CACornerMask = [.leftBottom, .leftTop]
  static var rightCorners: CACornerMask = [.rightBottom, .rightTop]
  static var topCorners: CACornerMask = [.leftTop, .rightTop]

}

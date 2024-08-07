//
//  CGRect+Operations.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 16.12.2020.
//

import UIKit

extension CGRect {
  
  mutating func move(x: CGFloat = 0.0,
                     y: CGFloat = 0.0) {
    origin.x += x
    origin.y += y
  }
  
  mutating func move(by offset: CGPoint) {
    move(x: offset.x, y: offset.y)
  }
  
  mutating func trim(left: CGFloat = 0.0,
                     right: CGFloat = 0.0,
                     top: CGFloat = 0.0,
                     bottom: CGFloat = 0.0) {
    origin.x += left
    size.width -= left + right
    
    origin.y += top
    size.height -= top + bottom
  }
  
  func moving(x offsetX: CGFloat = 0.0,
              y offsetY: CGFloat = 0.0) -> CGRect {
    var rect = self
    rect.move(x: offsetX, y: offsetY)
    
    return rect
  }
  
  func moving(by offset: CGPoint) -> CGRect {
    return moving(x: offset.x, y: offset.y)
  }
  
  func trimming(left: CGFloat = 0.0,
                right: CGFloat = 0.0,
                top: CGFloat = 0.0,
                bottom: CGFloat = 0.0) -> CGRect {
    var newRect = self
    newRect.trim(left: left, right: right, top: top, bottom: bottom)
    return newRect
  }
  
}

extension RectRepresented {
  
  var width: CGFloat {
    get { frame.width }
    set { frame.size.width = newValue }
  }
  
  var height: CGFloat {
    get { frame.height }
    set { frame.size.height = newValue }
  }
  
  var size: CGSize {
    get { frame.size }
    set { frame.size = newValue }
  }
  
  var origin: CGPoint {
    get { frame.origin }
    set { frame.origin = newValue }
  }
  
  var minX: CGFloat {
    get { origin.x }
    set { origin.x = newValue }
  }
  
  var maxX: CGFloat {
    get { size.width + origin.x }
    set { origin.x = newValue - width }
  }
  
  var minY: CGFloat {
    get { origin.y }
    set { origin.y = newValue }
  }
  
  var maxY: CGFloat {
    get { origin.y + size.height }
    set { origin.y = newValue - height }
  }
  
  var center: CGPoint {
    get { .init(x: origin.x + width / 2, y: origin.y + height / 2) }
    set { origin = .init(x: newValue.x - width / 2, y: newValue.y - height / 2) }
  }
  
}

protocol RectRepresented {
  var frame: CGRect { get set }
}

extension CGRect: RectRepresented {
  var frame: CGRect {
    get { self }
    set { self = newValue }
  }
}

extension UIView: RectRepresented {}

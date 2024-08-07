//
//  GradientView.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 15.12.2020.
//

import UIKit

final class GradientView: UIView {
  
  enum Direction {
    case horizontal, vertical
  }
  
  var direction = Direction.horizontal {
    didSet { updateView() }
  }
  
  override class var layerClass: Swift.AnyClass {
    return CAGradientLayer.self
  }
  
  var from: UIColor = .darkGray {
    didSet { updateView() }
  }
  
  var to: UIColor = .black {
    didSet { updateView() }
  }
  
  
  var startPoint: Float = 0.0 {
    didSet { updateView() }
  }
  
  var endPoint: Float = 1.0 {
    didSet { updateView() }
  }
  
  init() {
    super.init(frame: .zero)
    
    updateView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

}

private extension GradientView {
  
  private var gradientLayer: CAGradientLayer? {
    layer as? CAGradientLayer
  }
  
  private func updateView() {
    let colors: Array = [from.cgColor, to.cgColor]
    
    gradientLayer?.colors = colors
    if direction == .vertical {
      gradientLayer?.startPoint = .init(x: 0, y: 0)
      gradientLayer?.endPoint = .init(x: 0, y: 1)

    } else {
      gradientLayer?.startPoint = .init(x: 0, y: 1)
      gradientLayer?.endPoint = .init(x: 1, y: 1)
    }

    setNeedsDisplay()
  }
  
}


//
//  SplashTouchEffect.swift
//  PRSPR
//
//  Created by Oleksii Chernysh on 26.10.2021.
//

import UIKit

final class SplashTouchEffect: NSObject, TouchEffect {

  var color = UIColor.white.withAlphaComponent(0.35)
  private weak var control: UIControl?
  private let effectContainer = UIView()
  
  func apply(to control: UIControl) {
    self.control = control
    
    control.addTarget(self, action: #selector(touchBegin), for: .touchDown)
    
    with(effectContainer) {
      $0.layer.cornerCurve = control.touchDecorator.layer.cornerCurve
      $0.layer.cornerRadius = control.touchDecorator.layer.cornerRadius
    }.add(to: control.touchDecorator)
    .constrainEdgesToSuperview()
  }
      
  @objc
  private func touchBegin(_ sender: Any?, event: UIEvent) {
    addSplash()
  }
  
  private func addSplash() {
    effectContainer.clipsToBounds = true
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.frame = control?.bounds ?? .zero
    shapeLayer.path = UIBezierPath(rect: shapeLayer.frame).cgPath
    
    shapeLayer.fillColor = color.cgColor
    shapeLayer.strokeColor = UIColor.clear.cgColor
    effectContainer.layer.addSublayer(shapeLayer)
    
    let animation = with(CABasicAnimation.init(keyPath: "opacity")) {
      $0.toValue = CGFloat.zero
      $0.isRemovedOnCompletion = false
      $0.fillMode = .forwards
    }
    
    
    let duration = 0.5
    CATransaction.begin()
    CATransaction.setAnimationDuration(Double(duration))
    CATransaction.setAnimationTimingFunction(.init(name: .easeOut))
    shapeLayer.add(animation, forKey: "cool_alpha")
    CATransaction.commit()
  }
}

extension SplashTouchEffect: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    let la = anim.value(forKey: "animatedLayer")
    (la as? CALayer)?.removeFromSuperlayer()
  }
  
  func animationDidStart(_ anim: CAAnimation) {}
  
}

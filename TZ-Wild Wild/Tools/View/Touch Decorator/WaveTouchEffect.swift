//
//  WaveTouchEffect.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 22.03.2021.
//

import UIKit

final class WaveTouchEffect: NSObject, TouchEffect {

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
    guard
      let control = control,
      let touch = event.touches(for: control)?.first
    else { return }
    
    addCircle(at: touch.location(in: control))
  }
  
  private func addCircle(at loc: CGPoint) {
    effectContainer.clipsToBounds = true
    let circlePath = UIBezierPath(arcCenter: .init(x: 3, y: 3), radius: CGFloat(3), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.frame = .init(origin: loc, size: CGSize(width: 6, height: 6))
    shapeLayer.path = circlePath.cgPath
    
    shapeLayer.fillColor = color.cgColor
    shapeLayer.strokeColor = UIColor.clear.cgColor
    effectContainer.layer.addSublayer(shapeLayer)
    
    let a = CABasicAnimation.init(keyPath: "transform")
    a.toValue = CATransform3DMakeScale(effectContainer.width / 3, effectContainer.width / 3, 1.0)
    a.isRemovedOnCompletion = false
    a.setValue(shapeLayer, forKey: "animatedLayer")
    let op = CABasicAnimation.init(keyPath: "opacity")
    op.toValue = CGFloat.zero
    op.isRemovedOnCompletion = false
    op.fillMode = .forwards
    a.delegate = self
    
    let speed: CGFloat = 300.0
    
    let duration = effectContainer.width / speed
    CATransaction.begin()
    CATransaction.setAnimationDuration(Double(duration))
    CATransaction.setAnimationTimingFunction(.init(name: .easeOut))
    shapeLayer.add(a, forKey: "cool_thing")
    shapeLayer.add(op, forKey: "cool_alpha")
    CATransaction.commit()
  }
}

extension WaveTouchEffect: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    let la = anim.value(forKey: "animatedLayer")
    (la as? CALayer)?.removeFromSuperlayer()
  }
  
  func animationDidStart(_ anim: CAAnimation) {
    
  }
  
}

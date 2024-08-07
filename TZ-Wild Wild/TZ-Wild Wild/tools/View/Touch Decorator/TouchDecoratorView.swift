//
//  TouchDecoratorView.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 09.03.2021.
//

import UIKit
import CoreGraphics

final class TouchDecoratorView: UIView {
    
  private var effects = [TouchEffect]()
  
  var owner: UIControl!
  
  func addEffect(_ effect: TouchEffect) {
    effects.append(effect)
    effect.apply(to: self.owner)
  }
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    return false
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let l = touches.first!.location(in: owner)
    if owner!.point(inside: l, with: event) {
      owner.sendActions(for: .touchUpInside)
    }
    owner?.touchesEnded(touches, with: event)
  }
  
  @objc
  func touchBegin(_ sender: Any?, event: UIEvent) {
    guard let touch = event.touches(for: owner)?.first else { return }
    let loc = touch.location(in: owner)
  
    addCircle(at: loc)
  }
  
  func addCircle(at loc: CGPoint) {
    clipsToBounds = true
    let circlePath = UIBezierPath(arcCenter: .init(x: 3, y: 3), radius: CGFloat(3), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.frame = .init(origin: loc, size: CGSize(width: 6, height: 6))
    shapeLayer.path = circlePath.cgPath
    
    shapeLayer.fillColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
    shapeLayer.strokeColor = UIColor.clear.cgColor
    layer.addSublayer(shapeLayer)
    
    let a = CABasicAnimation.init(keyPath: "transform")
    a.toValue = CATransform3DMakeScale(self.frame.width / 3, self.frame.width / 3, 1.0)
    a.isRemovedOnCompletion = false
    a.setValue(shapeLayer, forKey: "animatedLayer")
    let op = CABasicAnimation.init(keyPath: "opacity")
    op.toValue = CGFloat.zero
    op.isRemovedOnCompletion = false
    op.fillMode = .forwards
    a.delegate = self
    
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.7)
    CATransaction.setAnimationTimingFunction(.init(name: .easeOut))
    shapeLayer.add(a, forKey: "cool_thing")
    shapeLayer.add(op, forKey: "cool_alpha")
    CATransaction.commit()
  }
}

extension TouchDecoratorView: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    let la = anim.value(forKey: "animatedLayer")
    (la as? CALayer)?.removeFromSuperlayer()
  }
  
  func animationDidStart(_ anim: CAAnimation) {
    
  }
}


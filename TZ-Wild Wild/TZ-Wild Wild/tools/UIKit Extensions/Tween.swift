//
//  Tween.swift
//  molfar.io
//
//  Created by Oleksii Chernysh on 02.03.2021.
//

import Foundation
import QuartzCore
import UIKit

final class Tween {
    
    var didUpdateValue: ((CGFloat) -> Void)?
    var completion: (() -> Void)?
    var mapper: ((CGFloat) -> AnyObject)?
    
    var timingFunction: CAMediaTimingFunction {
        set { layer.timingFunction = newValue }
        get { return layer.timingFunction }
    }
    
    private weak var object: UIView?
    private let key: String?
    
    private weak var layer: TweenLayer!
    
    init (object: UIView,
          key: String? = nil,
          from: CGFloat,
          to: CGFloat,
          duration: TimeInterval) {
        self.object = object
        self.key = key
        
        layer = {
            let layer = TweenLayer()
            layer.from = from
            layer.to = to
            layer.tweenDuration = duration
            layer.tween = self
            object.layer.addSublayer(layer)
            
            return layer
        }()
    }
    
    func start() {
        layer.startAnimation()
    }
    
}

extension Tween: TweenLayerDelegate {
    
    func tweenLayer(_ layer: TweenLayer, didSetAnimatableProperty newValue: CGFloat) {
        didUpdateValue?(newValue)
        guard let key = key else { return }
        if let mapper = mapper {
            object?.setValue(mapper(newValue), forKey: key)
        } else {
            object?.setValue(newValue, forKey: key)
        }
    }
    
    func tweenLayerDidStopAnimation(_ layer: TweenLayer) {
        completion?()
        layer.removeFromSuperlayer()
        self.layer = nil
    }
    
}

protocol TweenLayerDelegate: AnyObject {
    func tweenLayer(_ layer: TweenLayer, didSetAnimatableProperty to: CGFloat)
    func tweenLayerDidStopAnimation(_ layer: TweenLayer)
}

class TweenLayer: CALayer {
    
    @NSManaged fileprivate var animatableProperty: CGFloat
    var tween: TweenLayerDelegate?
    
    var from: CGFloat = 0.0
    var to: CGFloat = 0.0
    var tweenDuration: TimeInterval = 0.0
    var timingFunction = CAMediaTimingFunction(name: .linear)
    var delay: TimeInterval = 0.0
    
    override class func needsDisplay(forKey event: String) -> Bool {
        return event == "animatableProperty" ? true : super.needsDisplay(forKey: event)
    }
    
    override func action(forKey event: String) -> CAAction? {
        guard ["animatableProperty", "onOrderIn"].contains(event) else {
            return super.action(forKey: event)
        }
        
        let animation = CABasicAnimation(keyPath: event)
        animation.timingFunction = timingFunction
        animation.fromValue = from
        animation.toValue = to
        animation.duration = tweenDuration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.delegate = self as? CAAnimationDelegate
        
        return animation
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        tween?.tweenLayerDidStopAnimation(self)
    }
    
    override func display() {
        if let value = presentation()?.animatableProperty {
            tween?.tweenLayer(self, didSetAnimatableProperty: value)
            if value == to {
                tween?.tweenLayerDidStopAnimation(self)
                tween = nil
            }
        }
    }
    
    func startAnimation() {
        animatableProperty = to + 0.000000001
    }
    
}

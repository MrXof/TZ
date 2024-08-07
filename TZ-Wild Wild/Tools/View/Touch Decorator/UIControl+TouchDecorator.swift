//
//  UIControl+TouchDecorator.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 22.03.2021.
//

import UIKit

extension UIControl {

  func addtouchEffect(_ effect: TouchEffect) {
    touchDecorator.addEffect(effect)
  }
  
  private static var touchDecoratorKey: UInt8 = 0

  var touchDecorator: TouchDecoratorView {
    if let decorator = objc_getAssociatedObject(self, &UIControl.touchDecoratorKey) as? TouchDecoratorView {
      return decorator
    } else {
      let decorator = TouchDecoratorView()
      addSubview(decorator)
      decorator.owner = self
      decorator.frame = bounds
      decorator.constrainEdgesToSuperview()
      objc_setAssociatedObject(self, &UIControl.touchDecoratorKey,
                               decorator,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return decorator
    }
  }
  
}

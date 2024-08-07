//
//  ViewStylePrimitives.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 21.03.2021.
//

import UIKit

struct UIStyle {
  
  static func roundCorners<T: UIView>(_ r: CGFloat,
                                      corners: CACornerMask,
                                      cornerCurve: CALayerCornerCurve = .continuous) -> ViewStyle<T> {
    roundCorners(r, cornerCurve: cornerCurve) <> maskedCorners(corners: corners)
  }
  
  static func maskedCorners<T: UIView>(corners: CACornerMask) -> ViewStyle<T> {
    .init {
      $0.layer.maskedCorners = corners
    }
  }

  static func roundCorners<T: UIView>(_ r: CGFloat,
                                      cornerCurve: CALayerCornerCurve = .continuous) -> ViewStyle<T> {
    .init {
      with($0.layer) {
        $0.cornerRadius = r
        $0.cornerCurve = cornerCurve
        $0.masksToBounds = true
      }
    }
  }
  
  static func roundedCorners<T: UIView>() ->  ViewStyle<T> {
    .init { view in
      view.layer.masksToBounds = true
      view.publisher(for: \.layer.bounds).sink { [weak view ]frame in
        view?.layer.cornerRadius = min(frame.width, frame.height) / 2
      }.owned(by: view)
    }
  }
  
  static func rounded<T: UIView>() -> ViewStyle<T> {
    roundedCorners() <> .init {
      $0.aspectRatio(1.0)
    }
  }
  
  static func softShadow<T: UIView>() -> ViewStyle<T> {
    .init {
      with($0.layer) {
        $0.shadowColor = UIColor.hex("5D3B00").cgColor
        $0.shadowOffset = .init(width: .zero, height: 2.0)
        $0.shadowOpacity = 0.1
        $0.shadowRadius = 4.0
        $0.masksToBounds = false
      }
    }
  }
  
  static func blurBackground<T: UIView>(alpha: CGFloat) -> ViewStyle<T> {
    .init {
      let blurEffect = UIBlurEffect(style: .light)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      blurEffectView.frame = $0.bounds
      blurEffectView.alpha = alpha
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      $0.addSubview(blurEffectView)
    }
  }
  
  static func sketchShadow<T: UIView>() -> ViewStyle<T> {
    .init {
      with($0.layer) {
        $0.applySketchShadow()
      }
    }
  }
  
}

private extension CALayer {
  
  func applySketchShadow(color: UIColor = .black,
                         alpha: Float = 0.12,
                         x: CGFloat = .zero,
                         y: CGFloat = 3.0,
                         blur: CGFloat = 8.0,
                         spread: CGFloat = .zero) {
    masksToBounds = false
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
  
    if spread == 0.0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
    shouldRasterize = true
    rasterizationScale = UIScreen.main.scale
  }
  
}

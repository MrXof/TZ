//
//  ButtonStyles.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 22.03.2021.
//

import HandyText

extension UIStyle {
  
  static func waveEffect(_ color: UIColor) -> ViewStyle<UIButton> {
    .init {
      let effect = WaveTouchEffect()
      effect.color = color
      $0.addtouchEffect(effect)
    }
  }
  
  static let waveEffect: ViewStyle<UIButton> = .init {
    $0.addtouchEffect(WaveTouchEffect())
  }
  
  static let splashEffect: ViewStyle<UIButton> = .init {
    $0.addtouchEffect(SplashTouchEffect())
  }
  
}

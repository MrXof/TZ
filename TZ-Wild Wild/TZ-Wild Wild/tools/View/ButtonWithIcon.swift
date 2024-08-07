//
//  ButtonWithIcon.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 14.12.2020.
//

import UIKit

final class ButtonWithIcon: UIControl {
    
  var icon: UIImage? {
    didSet {
      iconImageView.image = icon
    }
  }
  
  var iconDiameter: CGFloat = 16.0 {
    didSet {
      iconImageView.snp.updateConstraints {
        $0.width.height.equalTo(iconDiameter)
      }
    }
  }
  
  override var contentMode: UIView.ContentMode {
    didSet {
      iconImageView.contentMode = contentMode
    }
  }
  
  private let iconImageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }

}

private extension ButtonWithIcon {
  
  func setup() {
    isUserInteractionEnabled = true
    with(iconImageView) {
      $0.isUserInteractionEnabled = true
      $0.contentMode = .scaleAspectFit
      addSubview($0)
      $0.snp.makeConstraints {
        $0.center.equalTo(self)
        $0.width.height.equalTo(iconDiameter)
      }
    }
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchUpInside))
    addGestureRecognizer(tapRecognizer)
  }
  
  @objc
  func touchUpInside(_ sender: Any?) {
    sendActions(for: .touchUpInside)
  }
  
}

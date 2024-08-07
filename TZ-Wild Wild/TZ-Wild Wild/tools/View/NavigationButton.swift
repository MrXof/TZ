//
//  NavigationButton.swift
//  OneCourt
//
//  Created by Oleksii Chernysh on 02.07.2021.
//

import UIKit

extension UIBarButtonItem {
  
  static func action(_ action: NavigationAction,
                     isTranslucent: Bool = false,
                     block: (() -> Void)? = nil) -> UIBarButtonItem {
    image(action.image, isTranslucent: isTranslucent, backgroundColor: action.backgroundColor, hasShadow: action.hasShadow, block: block)
  }
  
  static func image(_ image: UIImage,
                    isTranslucent: Bool = false,
                    backgroundColor: UIColor = .white,
                    iconColor: UIColor = .chicago,
                    selectedBackgroundColor: UIColor = .white,
                    selectedIconColor: UIColor = .chicago,
                    hasShadow: Bool = true,
                    block: (() -> Void)? = nil) -> UIBarButtonItem {
    let barHeight: CGFloat = 44.0
    let iconHeight: CGFloat = 36.0
    
    let container = UIView()
    
    with(NavigationButtonTintView()) {
      $0.constrainWidth(to: iconHeight)
        .constrainHeight(to: iconHeight)
        .add(to: container)
        .pinCenter()
      $0.backgroundColor = backgroundColor
      $0.isTranslucent = false
      $0.layer.masksToBounds = false
      if hasShadow {
        $0 |> UIStyle.softShadow()
      }
    }
        
    with(UIImageView()) {
      $0.image = image
      $0.contentMode = .scaleAspectFit
      $0.tintColor = iconColor
      $0.constrainWidth(to: min(image.size.width, 20.0))
      $0.constrainHeight(to: min(image.size.height, 20.0))
        .add(to: container)
        .pinCenter()
    }
    
    container.frame.size = .init(width: barHeight, height: barHeight)
    container.setNeedsLayout()
    container.layoutIfNeeded()

    return .init(customView: NavigationButton(view: container,
                                              block: block))
  }
  
  static func title(_ title: String, block: (() -> Void)? = nil) -> UIBarButtonItem {
    let label = UILabel()
    label.frame.size.width = label.sizeThatFits(.init(width: 100, height: 100)).width
    label.frame.size.height = 44.0
    return .init(customView: NavigationButton(view: label, block: block))
  }
  
}

enum NavigationAction: String {
  
  case back, add, close, delete, fav, list, clear, scan, microphone
  
  var image: UIImage {
    UIImage.init(named: "navigation.\(rawValue)")!
  }
  
  var backgroundColor: UIColor {
    return switch self {
    case .microphone:
        .seashell
    default:
        .white
    }
  }
  
  var hasShadow: Bool {
    self != .microphone
  }
  
}

final class NavigationButton: UIView {
  
  private let view: UIView
  private let actionBlock: (() -> Void)?
  private let tintView = NavigationButtonTintView()

  
  init(view: UIView,
       block: (() -> Void)? = nil) {
    self.actionBlock = block
    self.view = view
   
    super.init(frame: .init(origin: .zero,
                            size: .init(width: view.width,
                                        height: view.height)))
    
    view.add(to: self)
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchUpInside))
    addGestureRecognizer(tapRecognizer)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  @objc
  private func touchUpInside(_ sender: Any?) {
    actionBlock?()
    
    view.animate(t: 0.1) {
      $0.transform = .init(scaleX: 1.1, y: 1.1)
    }.then(t: 0.2) {
      $0.transform = .identity
    }.whenFinished { _ in
    }.start()
  }
  
}

final class NavigationButtonTintView: UIView {
  
  private var blurView: UIVisualEffectView!
  private let backgroundView = NavigationButtonBackgroundView()
  
  var isTranslucent: Bool = false {
    didSet {
      blurView.isHidden = !isTranslucent
    }
  }
  
  override var backgroundColor: UIColor? {
    set {
      backgroundView.backgroundColor = newValue
    }
    get {
      return backgroundView.backgroundColor
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundView
      .then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 18.0
        $0.layer.masksToBounds = true
      }
      .add(to: self)
      .constrainEdgesToSuperview()
    
    with(UIVisualEffectView(effect: UIBlurEffect(style: .dark))) {
      $0.alpha = 1.0
      blurView = $0
    }
    .add(to: self)
    .constrainEdgesToSuperview()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
}

final class NavigationButtonBackgroundView: UIView {}

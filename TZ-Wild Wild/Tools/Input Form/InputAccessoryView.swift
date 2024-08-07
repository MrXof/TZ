//
//  InputAccessoryView.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 18.06.2021.
//

import UIKit

final class InputAccessoryView: UIInputView {
  
  enum ActionStyle {
    case next, done
  }
    
  init(actionStyle: ActionStyle, action: @escaping () -> Void) {
    super.init(frame: CGRect(x: .zero, y: .zero, width: .zero, height: 40.0),
               inputViewStyle: .keyboard)
    
    let hStack = with(UIStackView()) {
      $0.axis = .horizontal
    }.add(to: self)
    .pinToSuperview(leading: 6.0,
                    trailing: 6.0,
                    top: 5.0,
                    bottom: 0.0)

    hStack.addArrangedSubview(.spacer())
    
    with(UIButton()) {
      $0.contentEdgeInsets = .init(top: .zero,
                                   left: 20.0,
                                   bottom: .zero,
                                   right: 20.0)
      $0.layer.cornerRadius = 6.0
      $0.backgroundColor = backgroundColor(for: actionStyle)
      $0.setTitle(title(for: actionStyle), for: .normal)
      $0.addTouchAction {
        action()
      }
    }.add(to: hStack)

  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
}

private extension InputAccessoryView {
  
  func backgroundColor(for style: ActionStyle) -> UIColor {
    switch style {
    case .next: return .gray
    case .done: return .black
    }
  }
  
  func title(for style: ActionStyle) -> String {
    switch style {
    case .next: return "keyboard.input_action.next_field".localized
    case .done: return "keyboard.input_action.done".localized
    }
  }
}

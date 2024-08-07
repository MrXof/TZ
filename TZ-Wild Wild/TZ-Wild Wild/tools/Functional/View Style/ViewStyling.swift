//
//  ViewStyling.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 21.03.2021.
//

import UIKit

struct ViewStyle<T: UIView> {
  
  let style: ((T) -> Void)
  
}

infix operator <> : ForwardComposition

@discardableResult
func <><T: UIView>(lhs: ViewStyle<T>, rhs: ViewStyle<T>) -> ViewStyle<T> {
  return .init {
    _ = lhs.style($0)
    _ = rhs.style($0)
  }
}

infix operator >|> : ForwardApplication

func |><T: UIView>(view: T, style: ViewStyle<T>) -> Void {
  style.style(view)
}

//
//  UIView+Change.swift
//  OneCourt
//
//  Created by Oleksii Chernysh on 02.07.2021.
//

import UIKit

enum ViewChangeEffect {
  case slideHorizontally, slideVertically, zoom, blink
}

func performChange<T: UIView>(on view: T,
                              with effect: ViewChangeEffect,
                              change: @escaping (T) -> Void) {
  let animation: (@escaping (T) -> Void) -> Void
  switch effect {
  case .slideHorizontally: animation = Animator.slideHorizontally(view: view)
  case .slideVertically: animation = Animator.slideVertically(view: view)
  case .zoom: animation = Animator.zoom(view: view)
  case .blink: animation = Animator.blink(view: view)
  }
  animation(change)
}


private struct Animator {
  
  static func slideVertically<T: UIView>(view: T) -> (@escaping (T) -> Void) -> Void {
    { change in
      view.animate(t: 0.1) {
        $0.transform = .init(translationX: .zero, y: -7.0)
        $0.alpha = .zero
      }.whenFinished {
        $0.transform = .init(translationX: .zero, y: 7.0)
        change(view)
      }.then(t: 0.1) {
        $0.transform = .identity
        $0.alpha = 1.0
      }.start()
    }
  }
  
  static func slideHorizontally<T: UIView>(view: T) -> (@escaping (T) -> Void) -> Void {
    { change in
      view.animate(t: 0.1) {
        $0.transform = .init(translationX: -7.0, y: .zero)
        $0.alpha = .zero
      }.whenFinished {
        $0.transform = .init(translationX: 7.0, y: .zero)
        change(view)
      }.then(t: 0.1) {
        $0.transform = .identity
        $0.alpha = 1.0
      }.start()
    }
  }
  
  static func zoom<T: UIView>(view: T) -> (@escaping (T) -> Void) -> Void {
    { change in
      view.animate(t: 0.1) {
        $0.transform = .init(scaleX: 0.95, y: 0.95)
        $0.alpha = .zero
      }.whenFinished {
        $0.transform = .init(scaleX: 1.05, y: 1.05)
        change(view)
      }.then(t: 0.1) {
        $0.transform = .identity
        $0.alpha = 1.0
      }.start()
    }
  }
  
  static func blink<T: UIView>(view: T) -> (@escaping (T) -> Void) -> Void {
    { change in
      view.animate(t: 0.1) {
        $0.alpha = .zero
      }.whenFinished { _ in
        change(view)
      }.then(t: 0.5) {
        $0.alpha = 1.0
      }.start()
    }
  }
  
}

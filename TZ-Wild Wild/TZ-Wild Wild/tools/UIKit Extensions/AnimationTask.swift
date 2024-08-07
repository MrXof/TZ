//
//  AnimationTask.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import UIKit

protocol Animatable {}
extension UIView: Animatable {}

final class AnimationTask<T: Animatable> {
  
  private let block: (T) -> Void
  private var completions = [(() -> Void)]()
  private let duration: TimeInterval
  private let delay: TimeInterval
  private let object: T
  private var assignedStartAction: (() -> Void)?
  
  init(object: T,
       duration: TimeInterval,
       delay: TimeInterval,
       block: @escaping (T) -> Void) {
    self.block = block
    self.duration = duration
    self.object = object
    self.delay = delay
  }
  
  func start() {
    if let startAction = assignedStartAction {
      startAction()
      assignedStartAction = nil
      return
    }
    
    UIView.animate(withDuration: duration,
                   delay: delay,
                   options: [.curveEaseOut], animations: {
                    self.block(self.object)
                   }) { completed in
      if completed {
        self.completions.forEach { $0() }
      }
    }
  }
  
  func then(t: TimeInterval = 1.0,
            delay: TimeInterval = .zero,
            block: @escaping (T) -> Void)
  -> AnimationTask<T> {
    let task = AnimationTask(object: object,
                             duration: t,
                             delay: delay,
                             block: block)
    completions.append {
      task.start()
    }
    task.assignedStartAction = {
      self.start()
    }
    
    return task
  }
  
  func whenFinished(_ block: @escaping (T) -> Void) -> AnimationTask<T> {
    completions.append {
      block(self.object)
    }
    return self
  }
  
}

extension Animatable {
  
  func animate(t: TimeInterval = 1.0,
               delay: TimeInterval = .zero,
               block: @escaping ((Self) -> Void)) -> AnimationTask<Self> {
    return AnimationTask(object: self,
                         duration: t,
                         delay: delay,
                         block: block)
  }
  
}

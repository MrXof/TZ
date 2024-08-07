//
//  CallBuffer.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 05.01.2021.
//

import Foundation

final class CallBuffer {
  
  var call: (() -> Void)
  private let delay: TimeInterval
  private var timer: Timer?
  
  deinit {
    invalidate()
  }
  
  init(delay: TimeInterval = 0.25,
       call: @escaping () -> Void) {
    self.delay = delay
    self.call = call
  }
  
  func scheduleCall() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: delay,
                                 repeats: false) { [weak self] _ in
      self?.call()
    }
  }
  
  func invalidate() {
    timer?.invalidate()
    timer = nil
  }
  
}

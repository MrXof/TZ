//
//  ProcessCounter.swift
//  OneCourt
//
//  Created by Oleksii Chernysh on 06.07.2021.
//

import Foundation

final class ProcessCounter {
  
  private var count = 0 {
    didSet {
      if oldValue > 0 && count == 0 {
        whenFree?()
      } else if oldValue == 0 && count > 0 {
        whenBusy?()
      }
    }
  }
  
  var whenFree: (() -> Void)?
  var whenBusy: (() -> Void)?
  
  func increase() {
    count += 1
  }
  
  func decrease() {
    count = max(0, count - 1)
  }
  
}

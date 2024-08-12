//
//  GameModule.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 09.08.2024.
//

import Foundation

final class GameModule: ObservableObject {
  
  let parts = 7
  let currentPosition = Observable(3)
  let gameIsRunning = Observable(true)
  let gameScore = Observable(0)
  
  func moveUp() {
    if self.currentPosition.value > 0 {
      self.currentPosition.value -= 1
    } else {
      self.currentPosition.value -= 0
    }
  }
  
  func moveDown() {
    if self.currentPosition.value < self.parts - 1 {
      self.currentPosition.value += 1
    } else {
      self.currentPosition.value += 0
    }
  }
  
}

// Make Observable

class Observable<T> {
  
  private var observer: ((T) -> Void)?
  
  var value: T {
    didSet {
      observer?(value)
    }
  }
  
  init(_ value: T) {
    self.value = value
  }
  
  func observer(_ observer: @escaping (T) -> Void) {
    self.observer = observer
    observer(value)
  }
}

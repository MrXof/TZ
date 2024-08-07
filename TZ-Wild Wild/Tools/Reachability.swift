//
//  Reachability.swift
//  PRSPR
//
//  Created by Oleksii Chernysh on 20.10.2021.
//

import Reachability

final class ReachabilityChecker: Service {
  
  var environment: ServiceLocator!
  
  let isReachable = Observable(false)
  
  private let reachability = try! Reachability()
  
  private lazy var updateBuffer = CallBuffer(delay: 0.2) { [weak self] in
    self?.updateStateIfNeeded()
  }
  
  init() {
    updateStateIfNeeded()
    
    reachability.whenReachable = { [weak self] _ in
      self?.updateBuffer.scheduleCall()
    }
    
    reachability.whenUnreachable = { [weak self] _ in
      self?.updateBuffer.scheduleCall()
    }
    
    try? reachability.startNotifier()
  }
  
  private func updateStateIfNeeded() {
    let newState = reachability.connection != .unavailable
    if isReachable.value != newState {
      isReachable.value = newState
    }
  }
  
}


//
//  ServiceLocator.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 10.02.2021.
//

import Foundation

final class ServiceLocator {
  
  private var services: [String: Any] = [:]
    
  func register<T>(_ service: T) {
    if var service = service as? Service {
      service.environment = self
    }
    services["\(T.self)"] = service
  }
  
  public func getService<T>() -> T {
    services["\(T.self)"] as! T
  }
  
  //Lifecycle
  
  func takeOff() {
    for service in services.values {
      if let service = service as? Service { service.takeOff() }
    }
  }
  
  func prepareToClose() {
    services.values.forEach { if let service = $0 as? Service { service.prepareToClose() } }
  }
  
}

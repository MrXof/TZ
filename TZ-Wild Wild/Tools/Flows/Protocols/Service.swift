//
//  Service.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 10.02.2021.
//

import Foundation

protocol Service {
  
  func takeOff()
  
  func prepareToClose()
  
  var environment: ServiceLocator! { get set }
  
}

extension Service {
  
  func takeOff() {}
  func prepareToClose() {}
  
}

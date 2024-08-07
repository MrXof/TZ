//
//  Flow.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import UIKit

class Flow: Module {
  
  var rootViewController: UIViewController!
    
  lazy var router: FlowPresentationRouter = with(.modal) { $0.owner = self } {
    didSet { router.owner = self }
  }
  
  override func prepareToClose() {
    children.compactMap { $0 as? Flow }.forEach { $0.router.dismiss() }
    
    super.prepareToClose()
  }
  
  override func close() {
    router.dismiss()
    super.close()
  }
  
  func start() {
    router.present()
  }
  
}

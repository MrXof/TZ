//
//  FlowPresentationRouter.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 17.05.2021.
//

import UIKit

class FlowPresentationRouter {
  
  var navigationController: UINavigationController!
  
  weak var owner: Flow?
  
  func dismiss() {}
  
  func present() {}
  
}

extension FlowPresentationRouter {
  
  static var modal: FlowPresentationRouter {
    ModalFlowPresentationRouter()
  }
  
  static func modal(presenter: UIViewController?) -> FlowPresentationRouter {
    ModalFlowPresentationRouter(presenter: presenter)
  }
  
  static var builtIn: FlowPresentationRouter {
    BuiltInFlowPresentationRouter()
  }
  
}

private final class BuiltInFlowPresentationRouter: FlowPresentationRouter {

  private weak var anchorViewController: UIViewController?
  
  private var initialBarColor: UIColor?
  
  override var navigationController: UINavigationController! {
    get {
      (owner?.parent as? Flow)?.rootViewController as? UINavigationController
    }
    set {
      fatalError()
    }
  }
  
  override func present() {
    initialBarColor = navigationController?.navigationBar.backgroundColor
  }
  
  override func dismiss() {
    if let anchor = anchorViewController {
      navigationController.popToViewController(anchor, animated: true)
    } else {
      navigationController?.pop()
    }
    
    if let initialColor = initialBarColor {
      navigationController?.navigationBar.setColor(initialColor)
    }
  }
  
}

private final class ModalFlowPresentationRouter: FlowPresentationRouter {
  
  private var presenter: UIViewController?
  
  init(presenter: UIViewController? = nil) {
    self.presenter = presenter
    
    super.init()
    
    navigationController = UINavigationController()
  }
  
  override func present() {
    if let presenter = presenter ?? (owner?.parent as? Flow)?.rootViewController,
       let ownerRepresentation = owner?.rootViewController {
      presenter.present(ownerRepresentation)
    }
  }
  
  override func dismiss() {
    owner?.rootViewController.dismiss()
  }
  
}

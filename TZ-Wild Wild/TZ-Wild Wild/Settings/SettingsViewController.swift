//
//  SettingsViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit

class SettingsViewController: UIViewController {
  
  weak var delegate: SettingsViewControllerDelegate?
  @IBOutlet weak var scoreLabel: UILabel!
  
  let module = GameModule()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBinding()
  }
  
  @IBAction func closeSettings(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBAction func exitGame(_ sender: Any) {
    dismiss(animated: true) {
      self.delegate?.settingsViewControllerDidRequestExitGame(self)
    }
  }
  
}

private extension SettingsViewController {
  
  func setupBinding() {
    module.gameScore.observer { [weak self] in
      self?.scoreLabel.text = "Score:\($0)"
    }
  }
  
}


protocol SettingsViewControllerDelegate: AnyObject {
  func settingsViewControllerDidRequestExitGame(_ controller: SettingsViewController)
}

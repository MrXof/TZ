//
//  SettingsViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit

class SettingsViewController: UIViewController {
  
  weak var delegate: SettingsViewControllerDelegate?
  
  let module = GameModule()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func closeSettings(_ sender: Any) {
    delegate?.settingsViewControllerDidClose(self)
    dismiss(animated: true)
  }
  
  @IBAction func exitGame(_ sender: Any) {
    dismiss(animated: true) {
      self.delegate?.settingsViewControllerDidRequestExitGame(self)
    }
  }
  
}

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewControllerDidRequestExitGame(_ controller: SettingsViewController)
    func settingsViewControllerDidClose(_ controller: SettingsViewController)
}

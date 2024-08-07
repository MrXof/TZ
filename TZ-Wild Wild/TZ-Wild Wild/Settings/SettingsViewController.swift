//
//  SettingsViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBAction func closeSettings(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBAction func exitGame(_ sender: Any) {
    dismiss(animated: true)
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "Main") as! ViewController
    navigationController?.pushViewController(controller, animated: true)
  }
  
}

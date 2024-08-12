//
//  ViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
  }
  
  @IBAction func showGameViewController(_ sender: Any) {
    let storyBoard = UIStoryboard(name: "GameViewController", bundle: nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func showAboutViewContoller(_ sender: Any) {
    let storyBoard = UIStoryboard(name: "AboutViewContoller", bundle: nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "AboutViewContoller") as! AboutViewContoller
    present(controller, animated: true)
  }
  
  @IBAction func showSettingsViewContoller(_ sender: Any) {
    let alert = UIAlertController(title: "Coming Soon", message: "This feature is coming soon!", preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    
    present(alert, animated: true, completion: nil)
  }
  
}

//
//  GameViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit

final class GameViewController: UIViewController {
  
  @IBOutlet weak var fivePosition: UIImageView!

  var planePosition = [UIImageView]()
  var currentPosition = 5
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
    
  @IBAction func showSettingsDetails(_ sender: Any) {
    let storyBoard = UIStoryboard(name: "SettingsViewController", bundle: nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
    
    if let sheet = controller.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 20
    }
    
    present(controller, animated: true)
  }
  
  
  @IBAction func up(_ sender: Any) {
    if currentPosition > 0 {
      planePosition[currentPosition].image = nil
      currentPosition -= 1
      planePosition[currentPosition].image = UIImage(systemName: "airplane")
    }
  }
  
  @IBAction func down(_ sender: Any) {
    if currentPosition < planePosition.count - 1 {
      planePosition[currentPosition].image = nil
      currentPosition += 1
      planePosition[currentPosition].image = UIImage(systemName: "airplane")
    }
  }
  
}

private extension GameViewController {
  
  func setup() {
  }
  
}

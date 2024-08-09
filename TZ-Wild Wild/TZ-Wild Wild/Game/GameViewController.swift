//
//  GameViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit

final class GameViewController: UIViewController {
  
  @IBOutlet weak var airPlaneImageView: UIImageView!
  @IBOutlet weak var partsView: UIView!
  @IBOutlet weak var cloud: UIImageView!
  
  private let module = GameModule()
  private var cloudAnimations: [UIImageView: (startX: CGFloat, duration: TimeInterval)] = [:]

  
  var currentPosition = Int()
  var clouds: [UIImageView] = []
  var gameIsRunning = true
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startCloudsAnimation()
    setupBinding()
  }
  
  @IBAction func showSettingsDetails(_ sender: Any) {
    pauseGame()
    let storyBoard = UIStoryboard(name: "SettingsViewController", bundle: nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
    controller.delegate = self
    present(controller, animated: true)
  }
  
  @IBAction func up(_ sender: Any) {
    module.moveUp()
    self.setImageViewPosition()
  }
  
  @IBAction func down(_ sender: Any) {
    module.moveDown()
    self.setImageViewPosition()
  }
      
}

private extension GameViewController {
  
  func setupBinding() {
    module.currentPosition.observer { [weak self] in
      self?.currentPosition = $0
    }
    module.gameIsRunning.observer { [weak self] in
      self?.gameIsRunning = $0
    }
  }
  
  func setImageViewPosition() {
    let partHeight = partsView.frame.height / CGFloat(self.module.parts)
    let newY = partHeight * CGFloat(self.currentPosition) + (partHeight - self.airPlaneImageView.frame.height) / 2
    
    UIView.animate(withDuration: 0.3) {
      self.airPlaneImageView.frame.origin.y = newY
      self.view.layoutIfNeeded()
    }
  }
  
  func startCloudsAnimation() {
    for _ in 0..<1 {
      createAndAnimateCloud()
    }
  }
  
  func createAndAnimateCloud() {
    let cloud = UIImageView(image: UIImage(systemName: "cloud.fill"))
    cloud.tintColor = .white
    clouds.append(cloud)
    
    let startX = partsView.frame.width
    let cloudHeight: CGFloat = 50
    
    let possiblePositionsY = (0..<module.parts).map { position -> CGFloat in
      let partHeight = partsView.frame.height / CGFloat(module.parts)
      return partHeight * CGFloat(position) + (partHeight - cloudHeight) / 2
    }
    
    let startY = possiblePositionsY.randomElement()!
    
    cloud.frame = CGRect(x: startX, y: startY, width: cloudHeight, height: cloudHeight)
    
    partsView.addSubview(cloud)
    
    let duration = TimeInterval(CGFloat.random(in: 4...8))
    
    UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
      cloud.frame.origin.x = -cloud.frame.width
    }, completion: { _ in
      cloud.removeFromSuperview()
      if let index = self.clouds.firstIndex(of: cloud) {
        self.clouds.remove(at: index)
      }
      if self.gameIsRunning {
        self.createAndAnimateCloud()
      }
    })
  }
  
  func resumeCloudAnimation(cloud: UIImageView, startX: CGFloat, duration: TimeInterval) {
    cloud.frame.origin.x = startX
    UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
      cloud.frame.origin.x = -cloud.frame.width
    }, completion: { _ in
      cloud.removeFromSuperview()
      if let index = self.clouds.firstIndex(of: cloud) {
        self.clouds.remove(at: index)
      }
      if self.gameIsRunning {
        self.createAndAnimateCloud()
      }
    })
  }
  
  func pauseGame() {
    module.gameIsRunning.value = false
    for cloud in clouds {
      let cloudLayer = cloud.layer.presentation() ?? cloud.layer
      let startX = cloudLayer.frame.origin.x
      let duration = TimeInterval((partsView.frame.width - startX) / cloud.frame.width * 8.0)
      cloudAnimations[cloud] = (startX: startX, duration: duration)
      cloud.layer.removeAllAnimations()
    }
  }
  
  func resumeGame() {
    module.gameIsRunning.value = true
    for (cloud, (startX, duration)) in cloudAnimations {
      resumeCloudAnimation(cloud: cloud, startX: startX, duration: duration)
    }
    cloudAnimations.removeAll()
  }
  
}

extension GameViewController: SettingsViewControllerDelegate {
  
  func settingsViewControllerDidRequestExitGame(_ controller: SettingsViewController) {
    resumeGame()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "Main") as! ViewController
    navigationController?.pushViewController(controller, animated: true)
  }
  
  func settingsViewControllerDidClose(_ controller: SettingsViewController) {
    resumeGame()
  }
  
}

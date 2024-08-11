//
//  GameViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit

final class GameViewController: UIViewController {
  
  @IBOutlet weak var partsView: UIView!
  @IBOutlet weak var scoreLabel: UILabel!
  
  private let module = GameModule()
  private var cloudAnimations: [UIImageView: (startX: CGFloat, duration: TimeInterval)] = [:]
  
  var currentPosition = Int()
  var clouds: [UIImageView] = []
  var gameIsRunning = true
  var airplane: UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startCloudsAnimation()
    setupBinding()
    self.setImageViewPosition()
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
    if airplane == nil {
      airplane = UIImageView(image: UIImage(systemName: "airplane"))
      airplane?.tintColor = .red
      if let airplane = airplane {
        partsView.addSubview(airplane)
      }
    }
    
    guard let airplane = airplane else { return }
    
    let partHeight = partsView.frame.height / CGFloat(self.module.parts)
    airplane.frame.size = CGSize(width: 70, height: partHeight)
    let newY = partHeight * CGFloat(self.currentPosition) + (partHeight - airplane.frame.height) / 2
    
    UIView.animate(withDuration: 0.3) {
      airplane.frame.origin.y = newY
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
    cloud.tintColor = .gray
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
    
    let cloudAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear) {
      cloud.frame.origin.x = self.airplane?.frame.origin.x ?? -cloud.frame.width
    }
    
    cloudAnimation.addCompletion { position in
      if position == .end {
        if self.checkCollision(with: cloud) {
          self.handleCollision()
        } else {
          UIView.animate(withDuration: duration / 2, delay: 0, options: [.curveLinear], animations: {
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
      }
    }
    
    cloudAnimation.startAnimation()
  }
  
  func checkCollision(with cloud: UIImageView) -> Bool {
    guard let airplane = airplane else { return false }
    
    let cloudFrame = cloud.frame
    let airplaneFrame = airplane.frame
    
    print("Checking collision: cloudFrame = \(cloudFrame), airplaneFrame = \(airplaneFrame)")
    
    return cloudFrame.intersects(airplaneFrame)
  }
  
  func handleCollision() {
    let alert = UIAlertController(title: "Game Over", message: "You've collided with a cloud. Would you like to restart or exit?", preferredStyle: .alert)
    
    let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
      self.restartGame()
    }
    let exitAction = UIAlertAction(title: "Exit", style: .destructive) { _ in
      self.exitGame()
    }
    
    alert.addAction(restartAction)
    alert.addAction(exitAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  func restartGame() {
    currentPosition = 0
    clouds.forEach { $0.removeFromSuperview() }
    clouds.removeAll()
    setImageViewPosition()
    startCloudsAnimation()
    module.gameIsRunning.value = true
  }
  
  func exitGame() {
    navigationController?.popToRootViewController(animated: true)
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

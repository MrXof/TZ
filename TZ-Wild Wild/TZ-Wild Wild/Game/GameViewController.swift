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
  private var fuelAnimations: [(UIImageView, startX: CGFloat, duration: TimeInterval)] = []
  
  var currentPosition = Int()
  var clouds: [UIImageView] = []
  var fuels: [UIImageView] = []
  var gameIsRunning = true
  var airplane: UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startCloudsAnimation()
    startFuelAnimation()
    setupBinding()
    setImageViewPosition()
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
    module.gameScore.observer { [weak self] in
      self?.scoreLabel.text = "Score: \($0)"
    }
  }
  
  // MARK: - PlaneImageView
  
  private func setImageViewPosition() {
    if airplane == nil {
      airplane = UIImageView(image: UIImage(systemName: "airplane"))
      airplane?.tintColor = .red
      if let airplane = airplane {
        partsView.addSubview(airplane)
      }
    }
    
    guard let airplane = airplane else { return }
    
    let partHeight = partsView.frame.height / CGFloat(self.module.parts)
    let width: CGFloat = 50
    let height = partHeight
    airplane.frame.size = CGSize(width: width, height: height)
    let newY = partHeight * CGFloat(self.currentPosition) + (partHeight - height) / 2
    
    let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      airplane.frame.origin.y = newY
    }
    
    animator.startAnimation()
  }
  
  // MARK: - Cloud
  
  func startCloudsAnimation() {
    createAndAnimateCloud()
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
    let endX = -cloud.frame.width
    
    UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
      cloud.frame.origin.x = endX
    }, completion: { _ in
      self.updateCloudPosition(cloud)
      self.checkCollisions()
      cloud.removeFromSuperview()
      if let index = self.clouds.firstIndex(of: cloud) {
        self.clouds.remove(at: index)
      }
      if self.gameIsRunning {
        self.createAndAnimateCloud()
      }
    })
  }
  
  // MARK: - Fuel
  
  func startFuelAnimation() {
    createAndAnimateFuel()
  }
  
  func createAndAnimateFuel() {
    let fuel = UIImageView(image: UIImage(systemName: "drop.fill"))
    fuel.tintColor = .blue
    fuels.append(fuel)
    
    let startX = partsView.frame.width
    let fuelHeight: CGFloat = 50
    
    let possiblePositionsY = (0..<module.parts).map { position -> CGFloat in
      let partHeight = partsView.frame.height / CGFloat(module.parts)
      return partHeight * CGFloat(position) + (partHeight - fuelHeight) / 2
    }
    
    let startY = possiblePositionsY.randomElement()!
    
    fuel.frame = CGRect(x: startX, y: startY, width: fuelHeight, height: fuelHeight)
    partsView.addSubview(fuel)
    
    let duration = TimeInterval(CGFloat.random(in: 4...8))
    let endX = -fuel.frame.width
    
    UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
      fuel.frame.origin.x = endX
    }, completion: { _ in
      self.updateFuelPosition(fuel)
      self.checkCollisions()
      fuel.removeFromSuperview()
      if let index = self.fuels.firstIndex(of: fuel) {
        self.fuels.remove(at: index)
      }
      if self.gameIsRunning {
        self.createAndAnimateFuel()
      }
    })
  }
  
  // MARK: - Collision
  
  func checkCollisions() {
    for cloud in clouds {
      let collision = checkCollision(with: cloud.frame)
      print("Checking collision with cloud at frame: \(cloud.frame)")
      if collision {
        print("Collision detected with cloud!")
        handleCollision()
        return
      }
    }
    
    for fuel in fuels {
      let collision = checkCollision(with: fuel.frame)
      if collision {
        print("Collision detected with fuel!")
        module.gameScore.value += 1
        fuel.removeFromSuperview()
        fuels.removeAll { $0 == fuel }
      }
    }
  }
  
  func checkCollision(with endFrame: CGRect) -> Bool {
    guard let airplane = airplane else { return false }
    
    let airplaneFrame = airplane.frame
    let collision = endFrame.intersects(airplaneFrame)
    print("Checking collision with airplane at frame: \(airplaneFrame), result: \(collision)")
    return collision
  }
  
  func updateCloudPosition(_ cloud: UIImageView) {
    let cloudFrame = cloud.frame
    if cloudFrame.origin.x < 0 {
      cloud.frame.origin.x = 0
    }
  }
  
  func updateFuelPosition(_ fuel: UIImageView) {
    let fuelFrame = fuel.frame
    if fuelFrame.origin.x < 0 {
      fuel.frame.origin.x = 0
    }
  }
  
  // MARK: Handle
  
  func handleCollision() {
    pauseGame()
    let alert = UIAlertController(title: "Game Over", message: "Score: \(module.gameScore.value)", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
      self.restartGame()
    })
    alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { _ in
      self.exitGame()
    })
    
    present(alert, animated: true)
  }
  
  // MARK: - OtherSettings
  
  func restartGame() {
    currentPosition = 3
    clouds.forEach { $0.removeFromSuperview() }
    clouds.removeAll()
    fuels.forEach { $0.removeFromSuperview() }
    fuels.removeAll()
    setImageViewPosition()
    startCloudsAnimation()
    startFuelAnimation()
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
      self.clouds.removeAll { $0 == cloud }
      if self.gameIsRunning {
        self.createAndAnimateCloud()
      }
    })
  }
  
  func resumeFuelAnimation(fuel: UIImageView, startX: CGFloat, duration: TimeInterval) {
    fuel.frame.origin.x = startX
    UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
      fuel.frame.origin.x = -fuel.frame.width
    }, completion: { _ in
      fuel.removeFromSuperview()
      self.fuels.removeAll { $0 == fuel }
      if self.gameIsRunning {
        self.createAndAnimateFuel()
      }
    })
  }
  
  func pauseGame() {
    gameIsRunning = false
    cloudAnimations.removeAll()
    fuelAnimations.removeAll()
    
    for cloud in clouds {
      let duration = cloud.layer.presentation()?.animationKeys()?.compactMap { $0 }.compactMap {
        cloud.layer.animation(forKey: $0)?.duration
      }.first ?? 0
      cloudAnimations[cloud] = (startX: cloud.frame.origin.x, duration: duration)
      cloud.layer.removeAllAnimations()
    }
    
    for fuel in fuels {
      let duration = fuel.layer.presentation()?.animationKeys()?.compactMap { $0 }.compactMap {
        fuel.layer.animation(forKey: $0)?.duration
      }.first ?? 0
      fuelAnimations.append((fuel, startX: fuel.frame.origin.x, duration: duration))
      fuel.layer.removeAllAnimations()
    }
  }
  
  func resumeGame() {
    gameIsRunning = true
    for (cloud, (startX, duration)) in cloudAnimations {
      resumeCloudAnimation(cloud: cloud, startX: startX, duration: duration)
    }
    for (fuel, startX, duration) in fuelAnimations {
      resumeFuelAnimation(fuel: fuel, startX: startX, duration: duration)
    }
  }
  
}

extension GameViewController: SettingsViewControllerDelegate {
  func settingsViewControllerDidRequestExitGame(_ controller: SettingsViewController) {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyBoard.instantiateViewController(withIdentifier: "Main") as! ViewController
    navigationController?.pushViewController(controller, animated: true)
  }
  
  func settingsViewControllerDidClose(_ controller: SettingsViewController) {
    resumeGame()
  }
}


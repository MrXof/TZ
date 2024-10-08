//
//  GameViewController.swift
//  TZ-Wild Wild
//
//  Created by Даниил Чугуевский on 07.08.2024.
//

import UIKit
import AVFoundation

final class GameViewController: UIViewController {
  
  @IBOutlet weak var partsView: UIView!
  @IBOutlet weak var scoreLabel: UILabel!
  
  private let module = GameModule()
  private var cloudAnimations: [UIImageView: (startX: CGFloat, duration: TimeInterval)] = [:]
  private var fuelAnimations: [(UIImageView, startX: CGFloat, duration: TimeInterval)] = []
  private var backgroundMusicPlayer: AVAudioPlayer?
  
  var currentPosition = Int()
  var clouds: [UIImageView] = []
  var fuels: [UIImageView] = []
  var gameIsRunning = true
  var airplane: UIImageView?
  
  private var difficultyLevel: Int = 1
  private let difficultyThreshold: [Int: (cloudDuration: ClosedRange<CGFloat>, fuelDuration: ClosedRange<CGFloat>)] = [
    1: (cloudDuration: 8...10, fuelDuration: 6...8),
    2: (cloudDuration: 6...8, fuelDuration: 3...7),
    3: (cloudDuration: 4...6, fuelDuration: 2...6)
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startCloudsAnimation()
    setupBackgroundMusic()
    startFuelAnimation()
    setupBinding()
    setImageViewPosition()
    addPanGestureToAirplane()
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
      self?.checkScoreAndUpdateDifficulty()
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
    for _ in 0..<3 {
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
    
    let duration = TimeInterval(CGFloat.random(in: difficultyThreshold[difficultyLevel]?.cloudDuration ?? 4...8))
    animateCloud(cloud: cloud, startX: startX, duration: duration)
  }
  
  func animateCloud(cloud: UIImageView, startX: CGFloat, duration: TimeInterval) {
    let halfDuration = duration / 2
    let endX = -cloud.frame.width
    
    UIView.animate(withDuration: halfDuration, delay: 0, options: [.curveLinear], animations: {
      cloud.frame.origin.x = endX / 2
    }, completion: { _ in
      self.checkCollisions()
      if self.gameIsRunning {
        let remainingDuration = halfDuration * 0.1
        UIView.animate(withDuration: remainingDuration, delay: 0, options: [.curveLinear], animations: {
          cloud.frame.origin.x = endX
        }, completion: { _ in
          self.updateCloudPosition(cloud)
          
          cloud.removeFromSuperview()
          self.clouds.removeAll { $0 == cloud }
          
          if self.gameIsRunning {
            self.createAndAnimateCloud()
          }
        })
      } else {
        cloud.removeFromSuperview()
        self.clouds.removeAll { $0 == cloud }
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
    
    let duration = TimeInterval(CGFloat.random(in: difficultyThreshold[difficultyLevel]?.fuelDuration ?? 4...8))
    animateFuel(fuel: fuel, startX: startX, duration: duration)
  }
  
  func animateFuel(fuel: UIImageView, startX: CGFloat, duration: TimeInterval) {
    let halfDuration = duration / 2
    let endX = -fuel.frame.width
    
    UIView.animate(withDuration: halfDuration, delay: 0, options: [.curveLinear], animations: {
      fuel.frame.origin.x = endX / 2
    }, completion: { _ in
      self.checkCollisions()
      if self.gameIsRunning {
        let remainingDuration = halfDuration * 0.1
        UIView.animate(withDuration: remainingDuration, delay: 0, options: [.curveLinear], animations: {
          fuel.frame.origin.x = endX
        }, completion: { _ in
          self.updateFuelPosition(fuel)
          fuel.removeFromSuperview()
          self.fuels.removeAll { $0 == fuel }
          if self.gameIsRunning {
            self.createAndAnimateFuel()
          }
        })
      } else {
        fuel.removeFromSuperview()
        self.fuels.removeAll { $0 == fuel }
      }
    })
  }
  
  // MARK: - Collision
  
  func checkCollisions() {
    guard gameIsRunning else { return }
    
    for cloud in clouds {
      if checkCollision(with: cloud.frame) {
        handleCollision()
        return
      }
    }
    
    for fuel in fuels {
      if checkCollision(with: fuel.frame) {
        module.gameScore.value += 1
        fuel.removeFromSuperview()
        fuels.removeAll { $0 == fuel }
      }
    }
  }

  
  func checkCollision(with endFrame: CGRect) -> Bool {
    guard let airplane = airplane else { return false }
    
    let airplaneFrame = airplane.frame
    print("Checking collision with airplane at frame: \(airplaneFrame), with object at frame: \(endFrame)")
    let collision = endFrame.intersects(airplaneFrame)
    print("Collision result: \(collision)")
    return collision
  }
  
  func updateCloudPosition(_ cloud: UIImageView) {
    let cloudFrame = cloud.frame
    if cloudFrame.origin.x < 0 {
      cloud.removeFromSuperview()
      self.clouds.removeAll { $0 == cloud }
    }
  }
  
  func updateFuelPosition(_ fuel: UIImageView) {
    let fuelFrame = fuel.frame
    if fuelFrame.origin.x < 0 {
      fuel.removeFromSuperview()
      self.fuels.removeAll { $0 == fuel }
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
  
  func setupBackgroundMusic() {
    guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else {
      print("Failed to find background music file.")
      return
    }
    
    do {
      backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
      backgroundMusicPlayer?.numberOfLoops = -1
      backgroundMusicPlayer?.prepareToPlay()
      backgroundMusicPlayer?.play()
    } catch {
      print("Failed to initialize AVAudioPlayer: \(error.localizedDescription)")
    }
  }
  
  func restartGame() {
    setupBackgroundMusic()
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
    let remainingDuration = (startX / partsView.frame.width) * duration
    UIView.animate(withDuration: remainingDuration, delay: 0, options: [.curveLinear], animations: {
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
    let remainingDuration = (startX / partsView.frame.width) * duration
    UIView.animate(withDuration: remainingDuration, delay: 0, options: [.curveLinear], animations: {
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
    backgroundMusicPlayer?.pause()
    gameIsRunning = false
    
    cloudAnimations.removeAll()
    for cloud in clouds {
      let startX = cloud.frame.origin.x
      let duration = TimeInterval((partsView.frame.width - startX) / cloud.frame.width * (difficultyThreshold[difficultyLevel]?.cloudDuration.upperBound ?? 8))
      cloudAnimations[cloud] = (startX, duration)
      cloud.layer.removeAllAnimations()
    }
    
    fuelAnimations.removeAll()
    for fuel in fuels {
      let startX = fuel.frame.origin.x
      let duration = TimeInterval((partsView.frame.width - startX) / fuel.frame.width * (difficultyThreshold[difficultyLevel]?.fuelDuration.upperBound ?? 8))
      fuelAnimations.append((fuel, startX, duration))
      fuel.layer.removeAllAnimations()
    }
  }

  func resumeGame() {
    if let player = backgroundMusicPlayer, !player.isPlaying {
      player.play()
    }
    gameIsRunning = true
    
    for (cloud, (startX, duration)) in cloudAnimations {
      resumeCloudAnimation(cloud: cloud, startX: startX, duration: duration)
    }
    cloudAnimations.removeAll()
    
    for (fuel, startX, duration) in fuelAnimations {
      resumeFuelAnimation(fuel: fuel, startX: startX, duration: duration)
    }
    fuelAnimations.removeAll()
  }
  
  func checkScoreAndUpdateDifficulty() {
    switch module.gameScore.value {
    case 0..<10:
      difficultyLevel = 1
    case 10..<20:
      difficultyLevel = 2
    case 20...:
      difficultyLevel = 3
    default:
      break
    }
  }
  
  // MARK: - PanGesture
  
  func addPanGestureToAirplane() {
    guard let airplane = airplane else { return }
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    airplane.isUserInteractionEnabled = true
    airplane.addGestureRecognizer(panGesture)
  }
  
  @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    guard let airplane = airplane else { return }
    
    let translation = sender.translation(in: partsView)
    
    airplane.center = CGPoint(x: airplane.center.x, y: airplane.center.y + translation.y)
    
    sender.setTranslation(.zero, in: partsView)
    
    if sender.state == .ended {
      checkCollisions()
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

//
//  UIDevice+Haptic.swift
//  mapin-ios
//
//  Created by Oleksandr Bielov on 27/12/2023.
//

import UIKit
import AudioToolbox

extension UIDevice {
  
  enum Haptic {
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case feedback(UIImpactFeedbackGenerator.FeedbackStyle)
    case selectionChanged
    case vibration
    
    
    var rawValue: String {
      switch self {
      case .notification(let feedbackType):
        return "notification"
      case .feedback(let feedbackStyle):
        return "feedback"
      case .selectionChanged:
        return "selectionChanged"
      case .vibration:
        return "AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)"
      }
    }
  }
  
  static func sendHaptic(with type: Haptic) {
    print(">>Sending haptic: \(type.rawValue)")
    switch type {
    case .notification(let feedbackType):
      UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    case .feedback(let feedbackStyle):
      UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    case .selectionChanged:
      UISelectionFeedbackGenerator().selectionChanged()
    case .vibration:
      AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
  }
  
}

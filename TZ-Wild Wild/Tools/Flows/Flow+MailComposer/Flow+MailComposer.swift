//
//  Flow+MailComposer.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 22.12.2020.
//

import UIKit
import MessageUI

struct MailComposerConfig {
  let email: String
  let subject: String
  let body: String
}

protocol MailComposing: MFMailComposeViewControllerDelegate {}

extension MailComposing where Self: Flow {
 
  func sendEmail(config: MailComposerConfig, sender: UIViewController? = nil) {
    if MFMailComposeViewController.canSendMail() {
      with(MFMailComposeViewController()) {
        $0.mailComposeDelegate = self
        $0.setToRecipients([config.email])
        $0.setMessageBody(config.body, isHTML: false)
        $0.setSubject(config.subject)
        (sender ?? rootViewController).present($0, animated: true)
      }
      return
    }
    sendGoogleMail(to: config.email, subject: config.subject) { completed in
      if !completed {
        self.showCantSendEmailAlert(sender: sender)
      }
    }
  }
  
  private func canSendGoogleMail(to: String, subject: String) -> Bool {
    guard let url = URL(string: self.googleUrlString(to: to, subject: subject)) else { return false }
    return UIApplication.shared.canOpenURL(url)
  }
  
  private func sendGoogleMail(to: String, subject: String, completion: @escaping ((Bool) -> Void)) {
    let url = URL(string: googleUrlString(to: to, subject: subject))!
    UIApplication.shared.open(url, options: [:], completionHandler: completion)
  }
  
  private func googleUrlString(to: String, subject: String) -> String {
    let urlBody = "to=\(to)&subject=\(subject)"
      .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    return "googlegmail:///co?" + urlBody
  }
  
  private func showCantSendEmailAlert(sender: UIViewController? = nil) {
    with(UIAlertController(
          title: "alert.cant_send_email.title".localized,
          message: "alert.cant_send_email.message".localized,
          preferredStyle: .alert)) {
      $0.addAction(.init(title: "general.action.ok".localized, style: .default))
      (sender ?? rootViewController).present($0, animated: true)
    }
  }
  
}

extension Flow {
  
  @objc(mailComposeController:didFinishWithResult:error:) func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error: Error?) {
    controller.dismiss(animated: true)
  }
  
}

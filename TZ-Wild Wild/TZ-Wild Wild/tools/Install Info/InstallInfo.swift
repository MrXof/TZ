//
//  InstallInfo.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 23.06.2021.
//

import Foundation

struct InstallInfo {
  
  static var id: String {
    var installId = UserDefaults.standard.string(forKey: "app_install_id")
    if installId == nil {
      installId = times(5) { "1234567890".randomElement() }
        .compactMap { $0 }
        .map(String.init)
        .joined()
      
      UserDefaults.standard.setValue(installId, forKey: "app_install_id")
      
    }
    
    return installId!
  }
  
}

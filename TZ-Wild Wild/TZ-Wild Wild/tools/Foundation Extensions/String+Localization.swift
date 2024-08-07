//
//  String+Localization.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import Foundation

extension String {
  
  var localized: String {
    NSLocalizedString(self, comment: "")
  }
    
}

extension String {
  
  static func unit(_ unit: String, _ amount: IntegerLiteralType) -> String {
    return String(format: unit.localized, amount)
  }
  
}

//
//  ApplicationError.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 01.06.2021.
//

import Foundation

struct ApplicationError: LocalizedError {
  
  enum Domain: String {
    case response
    case `internal`
    case store
  }
  
  let domain: Domain
  let code: Int
  let underlyingError: Error?
  
  init(domain: ApplicationError.Domain,
       code: Int,
       context: String? = nil,
       underlyingError: Error? = nil) {
    self.context = context
    self.domain = domain
    self.code = code
    self.underlyingError = underlyingError
  }
  
  var localizedDescription: String {
    let key = ["error", domain.rawValue, "\(code)", context]
      .compactMap { $0 }
      .joined(separator: ".")
    let localizedKey = key.localized
      
    if localizedKey != key {
      return localizedKey
    }
    
    let contextFreeKey = ["error", domain.rawValue, "\(code)"]
      .compactMap { $0 }
      .joined(separator: ".")
    
    let contextFreeKeyLocalized = contextFreeKey.localized
    
    if contextFreeKey != contextFreeKeyLocalized {
      return contextFreeKeyLocalized
    }
    
    if let underlyingDescription = underlyingError?.localizedDescription {
      return underlyingDescription
    }
    
    return "error.unknown".localized
  }
  
  var context: String?
  
  var underlyingDescription: String {
    (underlyingError as? LocalizedError)?.errorDescription ?? "Unknown"
  }
  
  var errorDescription: String? { return localizedDescription }
  
}

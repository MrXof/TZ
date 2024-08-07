//
//  ErrorClassifier.swift
//  PRPRS
//
//  Created by Oleksii Chernysh on 09.02.2021.
//

import Foundation

protocol ErrorClassifier {
  
  func classify(error: Error) -> ApplicationError
  
}

extension Error {
  
  func toInternal() -> ApplicationError {
    ApplicationErrorClassifier().classify(error: self)
  }
  
}

struct ApplicationErrorClassifier: ErrorClassifier {
  
  func classify(error: Error) -> ApplicationError {
    if let error = error as? ServerError {
      return ApplicationError(domain: .response, code: error.code, underlyingError: error)
    } else if error is ParserError {
      return ApplicationError(
        domain: .internal,
        code: 600,
        underlyingError: error)
    } else if let error = error as? ResponseError {
      return ApplicationError(domain: .response,
                              code: error.code,
                              underlyingError: error)
    } else if let error = error as? ConnectionError {
      return ApplicationError(domain: .internal, code: error.code)
    } else {
      return ApplicationError(domain: .internal,
                              code: 600)
    }
  }
  
}

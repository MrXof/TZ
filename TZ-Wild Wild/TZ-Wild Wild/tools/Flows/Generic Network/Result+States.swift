//
//  Result+States.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 07.06.2021.
//

import Foundation

extension Result {
  
  var success: Success? {
    if case .success(let value) = self {
      return value
    } else {
      return nil
    }
  }
  
  var error: Failure? {
    if case .failure(let error) = self {
      return error
    } else {
      return nil
    }
  }
  
  var isSuccess: Bool {
    return success != nil
  }
  
}

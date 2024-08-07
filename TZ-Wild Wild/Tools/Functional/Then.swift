//
//  Then.swift
//  InGreenient
//
//  Created by Andrii Sokur on 23.11.2021.
//

import Foundation

public protocol Then {}

extension Then where Self: AnyObject {
  
  @discardableResult
  public func then(_ block: (Self) throws -> Void) rethrows -> Self {
    try block(self)
    return self
  }

}

extension NSObject: Then {}
extension Request: Then {}

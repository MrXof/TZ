//
//  RequestExecuting.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 10.02.2021.
//

import Foundation

protocol RequestExecuting {
  
  @discardableResult
  func execute<T>(_ request: Request<T>) -> DataTask<T>?
  
  @discardableResult
  func dataTask<T>(for request: Request<T>) -> DataTask<T>?
  
}

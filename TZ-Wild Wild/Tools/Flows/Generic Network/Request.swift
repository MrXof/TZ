//
//  Request.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 09.02.2021.
//

import Foundation

enum RequestMethod {
  case get
  case post
  case put
  case delete
  case patch
}

final class Request<T> {
  
  let path: String
  let parser: ResponseParser<T>
  var method: RequestMethod = .get
  private(set) var params: [String: Any] = [:]
  
  init(path: String, parser: ResponseParser<T>) {
    self.path = path
    self.parser = parser
  }
  
  subscript(key: String) -> String? {
    get { params[key] as? String }
    set { params[key] = newValue }
  }
  
  subscript(key: String) -> Int? {
    get { params[key] as? Int }
    set { params[key] = newValue }
  }
  
  subscript(key: String) -> Double? {
    get { params[key] as? Double }
    set { params[key] = newValue }
  }
  
  subscript(key: String) -> Any? {
    get { params[key] }
    set { params[key] = newValue }
  }
  
}

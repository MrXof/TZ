//
//  Validator.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 16.02.2021.
//

import Foundation

enum Validated<T> {
  case valid(T)
  case notValid([ValidationError])
  
  var isValid: Bool {
    if case .valid(_) = self {
      return true
    }
    return false
  }
  
  var errors: [ValidationError] {
    if case .notValid(let errors) = self {
      return errors
    } else {
      return []
    }
  }
  
}

struct Validator<T> {
  
  var condition: (T) -> Validated<T>
  
  init(_ condition: @escaping (T) -> Validated<T>) {
    self.condition = condition
  }
  
  init(error: ValidationError, condition: @escaping (T) -> Bool) {
    self.init { condition($0) ? .valid($0) : .notValid([error]) }
  }
  
  func check(_ value: T) -> Validated<T> {
    return condition(value)
  }
  
}

extension Validator {
  
  static func alwaysValid<T>() -> Validator<T> {
    .init { .valid($0) }
    }
 
}

func &&<T>(lhs: Validator<T>, rhs: Validator<T>) -> Validator<T> {
  .init { t in
    let leftValidated = lhs.check(t)
    let rightValidated = rhs.check(t)
    
    let bothValid = leftValidated.isValid && rightValidated.isValid
    return bothValid ? .valid(t) : .notValid(leftValidated.errors + rightValidated.errors)
  }
}

func ||<T>(lhs: Validator<T>, rhs: Validator<T>) -> Validator<T> {
  .init { t in
    let leftValidated = lhs.check(t)
    
    guard !leftValidated.errors.isEmpty else {
      return .valid(t)
    }
    
    let rightValidated = rhs.check(t)
    if rightValidated.errors.isEmpty {
      return .valid(t)
    } else {
      return .notValid(leftValidated.errors + rightValidated.errors)
    }
  }
}

func not<T>(_ lhs: Validator<T>, _ error: ValidationError) -> Validator<T> {
  Validator<T>.init { t in
    let result = lhs.check(t)
    if result.errors.isEmpty {
      return .notValid([error])
    } else {
      return .valid(t)
    }
  }
}


struct ValidationError: Error {
  let text: String
}

func lengthEquals(_ length: Int, _ errorFormat: String) -> Validator<String> {
  .init(error: .init(text: errorFormat.format(length))) { $0.count == length }
}

func longerThan(_ minLength: Int, _ errorFormat: String) -> Validator<String> {
  .init(error: .init(text: errorFormat.format(minLength))) { $0.count > minLength }
}


func notLongerThan(_ maxLength: Int, _ errorFormat: String) -> Validator<String> {
  .init(error: .init(text: errorFormat.format(maxLength))) { $0.count <= maxLength }
}

func containsString(_ string: String, _ errorFormat: String) -> Validator<String> {
  .init(error: .init(text: errorFormat.format(string))) { $0.contains(string) }
}

func doesNotContain(_ string: String, _ errorFormat: String) -> Validator<String> {
  not(containsString(string, ""), .init(text: errorFormat.format(string)))
}

func hasPrefix(_ prefix: String, _ errorFormat: String) -> Validator<String> {
  .init(error: .init(text: errorFormat.format(prefix))) { $0.hasPrefix(prefix) }
}

func matchesRegexp(_ pattern: String, errorFormat: String) -> Validator<String> {
  .init(error: .init(text: errorFormat.format(pattern))) {
    guard let regexp = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
    return regexp.matches($0)
  }
}

func allowedCharacters(_ string: String, _ errorFormat: String) -> Validator<String> {
  .init(error: .init(text: errorFormat.format(string))) {
    var isValid = true
    $0.forEach {
      isValid = string.contains($0) && isValid
    }
    return isValid
  }
}


extension NSRegularExpression {
  
   func matches(_ string: String) -> Bool {
       let range = NSRange(location: 0, length: string.utf16.count)
       return firstMatch(in: string, options: [], range: range) != nil
   }
  
}

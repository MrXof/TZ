//
//  Preferences.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 11.03.2021.
//

import Foundation

final class Preferences: Service {
  
  var environment: ServiceLocator!
    
  private let defaults = UserDefaults.standard
  
  func get<T: Codable>() -> T? {
    guard let data = defaults.data(forKey: String(describing: T.self)),
      let value = try? JSONDecoder().decode(T.self, from: data) else {
        return nil
    }
    return value
  }
  
  func get<T: Codable>(fallback: T) -> T {
    get() ?? fallback
  }
  
  func set<T: Codable>(_ value: T) {
    if let data = try? JSONEncoder().encode(value) {
      defaults.setValue(data, forKey: String(describing: T.self))
    }
  }
  
  func reset<T: Codable>(_ type: T.Type) {
    defaults.removeObject(forKey: (String(describing: type)))
  }
  
  func on<P: Codable>(_ keyPath: ReferenceWritableKeyPath<Preferences, P>,
                      _ mutator: (inout P) -> Void) {
    var val = self[keyPath: keyPath]
    mutator(&val)
    set(val)
  }
  
}

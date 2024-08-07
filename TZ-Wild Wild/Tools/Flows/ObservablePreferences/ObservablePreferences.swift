//
//  ObservablePreferences.swift
//  InGreenient
//
//  Created by Andrii Sokur on 15.06.2022.
//

import Foundation

class ObservablePreferences: DisposeBagOwning {
  
  private let defaults: UserDefaults
  private(set) var disposeBag = DisposeBag()
  private var signalMap = [String: Any]()
  
  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }
  
  func property<T: Codable>(ofType type: T.Type, forKey key: String = String(describing: T.self)) -> Observable<T> {
    property(forKey: key)
  }
  
  func property<T: Codable>(forKey key: String = String(describing: T.self)) -> Observable<T> {
    let observableValue: Observable<T> = signal(forKey: key)
    observableValue
      .skip(1)
      .observe { [weak self] in
        self?.archive($0, forKey: key)
      }
      .owned(by: self)
    
    return observableValue
  }
  
  func get<T: Codable>(forKey key: String = String(describing: T.self)) -> T {
    let data = defaults.data(forKey: key) ?? (try! JSONEncoder().encode([String: String]()))
    return try! JSONDecoder().decode(T.self, from: data)
  }

  func archive<T: Codable>(_ value: T, forKey key: String = String(describing: T.self)) {
    if let data = try? JSONEncoder().encode(value) {
      defaults.setValue(data, forKey: key)
    }
  }
  
  func clean<T: Codable>(_ type: T.Type, forKey key: String = String(describing: T.self)) {
    let data = (try! JSONEncoder().encode([String: String]()))
    let object = try! JSONDecoder().decode(T.self, from: data)
    archive(object, forKey: key)
  }
    
}

private extension ObservablePreferences {
  
  func signal<T: Codable>(forKey key: String = String(describing: T.self)) -> Observable<T> {
    if let result = signalMap[key] as? Observable<T> {
      return result
    } else {
      let initialValue: T = get(forKey: key)
      let observableValue = Observable(initialValue)
      signalMap[key] = observableValue
      return observableValue
    }
  }
  
}

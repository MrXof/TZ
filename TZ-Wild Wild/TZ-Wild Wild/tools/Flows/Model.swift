//
//  Model.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 10.02.2021.
//

import Foundation

protocol ApplicationEventId {
  var rawValue: String { get }
  
}

extension ApplicationEventId {
  func isEqual(to otherId: ApplicationEventId) -> Bool {
    rawValue == otherId.rawValue
  }
}

struct ApplicationEvent {
  let id: ApplicationEventId
  let object: Any?
  
  init(id: ApplicationEventId, object: Any? = nil) {
    self.id = id
    self.object = object
  }
  
}

class Module: NSObject {
  
  let timestamp = Date()
  let error = Pipe<ApplicationError>()
  
  private(set) weak var parent: Module? {
    didSet { if parent != nil { didMoveToParent() }}
  }
  
  private(set) var children: Set<Module> = []
  
  func addChild(_ model: Module) {
    children.insert(model)
    model.parent = self
  }
  
  deinit {
    print(">>> DEINIT: \(String(describing: self))")
  }
  
  func removeChild(_ model: Module) {
    children.remove(model)
    model.parent = nil
  }
  
  func removeFromParent() {
    parent?.removeChild(self)
  }
  
  func didMoveToParent() {
    
  }
  
  func prepareToClose() {
    
  }
  
  func close() {
    prepareToClose()
    removeFromParent()
  }
  
  private var registeredEventIds = Set<String>()
  
  private func isRegisteredForEvent(_ eventId: String) -> Bool {
    registeredEventIds.contains(eventId)
  }
  
  final func register(for eventId: ApplicationEventId) {
    registeredEventIds.insert(eventId.rawValue)
  }
  
  final func raise(_ event: ApplicationEvent) {
    guard parent == nil else {
      parent?.raise(event)
      return
    }
    receive(event: event)
  }
  
  private func receive(event: ApplicationEvent) {
    if isRegisteredForEvent(event.id.rawValue) {
      handle(event)
    }
    children.forEach { $0.receive(event: event) }
  }
  
  func handle(_ event: ApplicationEvent) {
    
  }
  
  // Errors
  
  final func raise(_ error: Error, in context: String = "") {
    var applicationError = errorClassifier.classify(error: error)
    applicationError.context = context
    raise(applicationError)
  }
  
  final func raise(_ error: ApplicationError) {
    if isRegistered(for: error) {
      handle(error: error)
    } else {
      parent?.raise(error)
    }
  }
  
  func handle(error: ApplicationError) {
    self.error.send(error)
  }
  
  private(set) var errorPredicates = [ErrorPredicate]()
  
  private func isRegistered(for error: ApplicationError) -> Bool {
    errorPredicates
      .map { $0.check(error) }
      .reduce(false) { $0 || $1 }
  }
  
  func registerForErrors(domain: ApplicationError.Domain, codes: [Int]) {
    codes.forEach {
      registerForError(domain: domain, code: $0)
    }
  }
  
  func registerForError(domain: ApplicationError.Domain, code: Int) {
    errorPredicates.append(
      .init(description: "\(domain).\(code)")
        { $0.domain == domain && $0.code == code }
    )
  }
  
  func registerForErrors(domain: ApplicationError.Domain, codePrefix: Int) {
    errorPredicates.append(.init(description: "\(domain).\(codePrefix)xx") { error in
      return String(error.code).hasPrefix(String(codePrefix))
    })
  }
  
  func registerForErrors(predicateDescription: String,
                         predicate: @escaping (ApplicationError) -> Bool) {
    errorPredicates.append(.init(description: predicateDescription, check: predicate))
  }

}

struct ErrorPredicate {
  
  let description: String
  let check: (ApplicationError) -> Bool
  
}

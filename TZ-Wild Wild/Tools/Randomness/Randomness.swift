//
//  Randomness.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 17.03.2021.
//

import Foundation

protocol RandomnessSource {
  
  func random() -> Int
  
}

final class LinearCongruentialGenerator: RandomnessSource {
  
  private var state: Int
  
  let a = 214013
  let c = 2531011
  let m = 2147483648
  let shift = 16
  
  init(seed: Int = 0) {
    state = seed
  }
  
  func random() -> Int {
    state = (a * state + c) % m
    return state >> shift
  }
  
}

class TrueRandomNumberGenerator: RandomnessSource {
  
  func random() -> Int {
    Int.random(in: 0...Int(UINT32_MAX))
  }
  
}

struct Gen<A> {
  
  let run: (RandomnessSource) -> A
  
}

extension Gen where A: FixedWidthInteger {
  static func int(in range: ClosedRange<A>) -> Gen<A> {
    Gen<A> { rng in
      let random = rng.random()
      let rem = A(random) % (range.max()! - range.min()! + 1) + range.min()!
      return A(rem)
    }
  }
}

extension Gen {
  func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
    Gen<B> { f(self.run($0)) }
  }
}

extension Gen where A == Bool {
  static let bool: Gen<Bool> = Gen<Int>.int(in: 0...1).map { $0 % 2 == 0 }
}

extension Gen {
  static func always(_ a: A) -> Gen<A> {
    Gen { _ in a }
  }
}

extension Gen {
  static func element(in xs: [A]) -> Gen<A?> {
    Gen<Int>.int(in: 0...(max(0, xs.count - 1))).map { xs.isEmpty ? nil : xs[$0] }
  }
}

extension Gen {
  
  static func uniqueIndices(upTo maxIndex: Int, maxCount: Gen<Int>) -> Gen<[Int]> {
    Gen<[Int]> {
      var allIndices: [Int] = Array(0...maxIndex)
      let elementCount = min(maxCount.run($0), allIndices.count)

      var result = [Int]()

      for _ in 0..<elementCount {
        let randomIndex = Gen<Int>.element(in: Array(0..<allIndices.count)).run($0)!
        result.append(allIndices[randomIndex])
        allIndices.remove(at: randomIndex)
      }

      return result
    }
  }
  
  static func elements<A>(in array: [A], maxCount: Gen<Int>) -> Gen<[A]> {
    guard !array.isEmpty else { return Gen<[A]> { _ in [] } }
    return uniqueIndices(upTo: array.count - 1, maxCount: maxCount).map { $0.map { array[$0] } }
  }
  
}


//
//  Curves.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 03.06.2021.
//

import CoreGraphics

typealias Curve = (CGFloat) -> CGFloat?
typealias CurveModifier = (@escaping Curve) -> Curve

func linear() -> Curve {
  { $0 }
}

func arcTangent() -> Curve {
  { atan($0 * (.pi / 2.0)) / (.pi / 2.0) }
}

func circle() -> Curve {
  { sqrt(1.0 - pow((1.0 - $0), 2.0)) }
}

func define(from: CGFloat, to: CGFloat) -> CurveModifier {
{ f in
  { x in
    guard x >= from && x < to else { return nil }
    return f(x)
  }
  }
}

func define(from: CGFloat, through: CGFloat) -> CurveModifier {
{ f in
  { x in
    guard x >= from && x <= through else { return nil }
    return f(x)
  }
  }
}

func defineResult(from: CGFloat, through: CGFloat) -> CurveModifier {
  { f in
    { x in
      guard let result = f(x) else { return nil }
      guard result >= from && result <= through else { return nil }
      return result
    }
  }
}

func defineResult(from: CGFloat, to: CGFloat) -> CurveModifier {
  { f in
    { x in
      guard let result = f(x) else { return nil }
      guard result >= from && result < to else { return nil }
      return result
    }
  }
}

func offset(x offsetX: CGFloat = .zero,
            y offsetY: CGFloat = .zero) -> CurveModifier {
  { f in
    { x in
      guard let y = f(x - offsetX) else { return nil }
      return y + offsetY
    }
  }
}

func scale(x scaleX: CGFloat = 1.0, y scaleY: CGFloat = 1.0) -> CurveModifier {
{ f in
  { x in
    guard let y = f(x / scaleX) else { return nil }
    return y * scaleY
  }
  }
}

func combine(_ functions: Curve ...) -> Curve {
{ x in
  var result: CGFloat?
  for f in functions {
    if let y = f(x) {
      result = y
      break
    }
  }
  return result
  }
}

func sCurve(height: CGFloat,
            topTangent: CGFloat,
            bottomTangent: CGFloat) -> Curve {
  let linearPartHeight = height - bottomTangent
  return combine(
    arcTangent()
      |> scale(x: topTangent, y: topTangent)
      >>> define(from: -.infinity, to: .zero),
    linear()
      |> define(from: .zero, to: linearPartHeight),
    arcTangent()
      |> scale(x: bottomTangent, y: bottomTangent)
      >>> offset(x: linearPartHeight, y: linearPartHeight)
      >>> define(from: linearPartHeight, through: .infinity)
  )
}

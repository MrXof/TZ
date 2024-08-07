////
////  HeightCalculating.swift
////  OrthoGun
////
////  Created by Oleksii Chernysh on 18.06.2021.
////
//
//import UIKit
//
//protocol HeightCalculating {
//  
//  func height(atWidth width: CGFloat) -> CGFloat
//  
//}
//
//extension HeightCalculating where Self: UIView {
//  
//  func height(atWidth width: CGFloat) -> CGFloat {
//    calculateHeight(for: self, at: width)
//  }
//  
//}
//
//func calculateHeight(for view: UIView, at width: CGFloat) -> CGFloat {
//  let size = view.systemLayoutSizeFitting(.init(width: width, height: .zero), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
//
//  return size.height
//}
//
//protocol WidthCalculating {
//  
//  func width(atHeight height: CGFloat) -> CGFloat
//  
//}
//
//extension WidthCalculating where Self: UIView {
//  
//  func width(atHeight height: CGFloat) -> CGFloat {
//    let size = systemLayoutSizeFitting(.init(width: width, height: .zero), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
//
//    return size.height
//  }
//  
//}
//
//extension WidthCalculating where Self: UICollectionViewCell {
//  
//  func width(atHeight height: CGFloat) -> CGFloat {
//    let size = contentView.systemLayoutSizeFitting(
//      .init(width: .zero, height: height),
//      withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
//
//    return size.width
//  }
//  
//}
//
//protocol SizeCalculating {
//  
//  func prefferedSize() -> CGSize
//  
//}
//
//extension SizeCalculating where Self: UIView {
//  
//  func prefferedSize() -> CGSize {
//    calculateSize(for: self)
//  }
//  
//}
//
//func calculateSize(for view: UIView) -> CGSize {
//  let size = view.systemLayoutSizeFitting(
//    .zero,
//    withHorizontalFittingPriority: .fittingSizeLevel,
//    verticalFittingPriority: .fittingSizeLevel)
//
//  return size
//}

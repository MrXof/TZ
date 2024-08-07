//
//  Reusable.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 16.02.2021.
//

import UIKit

protocol Reusable {
  
  static var reuseIdentifier: String { get }
  
}

extension Reusable {
  
  static var reuseIdentifier: String {
      return String(describing: self)
  }
  
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
extension UICollectionReusableView: Reusable {}

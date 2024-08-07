//
//  UITableView+Dequeuing.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 10.12.2020.
//

import UIKit

extension UITableView {
  
  func registerCellClass<T: UITableViewCell>(_ cellClass: T.Type) {
    register(cellClass, forCellReuseIdentifier: String(describing: cellClass.self))
  }
  
  func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
    dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
  }
  
  func registerSectionHeaderClass<T: UITableViewHeaderFooterView>(_ headerClass: T.Type) {
    register(headerClass, forHeaderFooterViewReuseIdentifier: String(describing: headerClass.self))
  }
  
  func dequeueSectionHeader<T: UITableViewHeaderFooterView>(for section: Int) -> T {
    dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as! T
  }

}

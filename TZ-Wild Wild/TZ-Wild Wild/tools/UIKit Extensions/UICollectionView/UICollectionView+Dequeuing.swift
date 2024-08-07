//
//  UICollectionView+Dequeuing.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 09.12.2020.
//

import UIKit

extension UICollectionView {
  
  func registerCellClass<T: UICollectionViewCell>(_ cellClass: T.Type) {
    register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass.self))
  }
  
  func registerSupplementaryView<T: UICollectionReusableView>(_ headerClass: T.Type,
                                                              kind: String) {
    register(headerClass, forSupplementaryViewOfKind: kind,
             withReuseIdentifier: String(describing: headerClass.self))
  }
  
  func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
    dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
  }
  
  
  func dequeueSupplementaryView<T: UICollectionReusableView>(kind: String,
                                                             for indexPath: IndexPath) -> T {
    dequeueReusableSupplementaryView(ofKind: kind,
                                     withReuseIdentifier: String(describing: T.self),
                                     for: indexPath) as! T
  }
  
}

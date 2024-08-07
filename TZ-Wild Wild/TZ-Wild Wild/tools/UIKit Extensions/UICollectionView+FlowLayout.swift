//
//  UICollectionView+FlowLayout.swift
//  Trakr
//
//  Created by Andrii Sokur on 10/7/23.
//

import UIKit

extension UICollectionView {
  
  static func withFlowLayout() -> UICollectionView {
    UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  }
  
  var flowLayout: UICollectionViewFlowLayout {
    collectionViewLayout as! UICollectionViewFlowLayout
  }
  
}

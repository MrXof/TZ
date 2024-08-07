//
//  FreeDecorationBehavior.swift
//  OrthoGun
//
//  Created by Oleksii Chernysh on 18.06.2021.
//

import UIKit

final class FreeDecorationBehavior: NSObject, CollectionViewBehavior {
  
  var collectionView: UICollectionView!
  
  var willDisplayCell: ((UICollectionViewCell) -> Void)?
  
  func collectionView(_ collectionView: UICollectionView,
                      willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    willDisplayCell?(cell)
  }
}

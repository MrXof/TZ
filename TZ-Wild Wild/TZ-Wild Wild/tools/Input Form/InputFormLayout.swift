//
//  InputFormLayout.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 15.02.2021.
//

import UIKit

protocol InputFormLayoutDataSource: AnyObject {
  
  func inputFormLayout(_ layout: InputFormLayout,
                       itemHeightAt indexPath: IndexPath) -> CGFloat
  
  func inputFormLayout(_ layout: InputFormLayout,
                       isFieldHiddenAt indexPath: IndexPath) -> Bool

  func inputFormLayout(_ layout: InputFormLayout,
                       validationErrorViewHeightAt indexPath: IndexPath) -> CGFloat

  func verticalItemSpacingForLayout(_ layout: InputFormLayout, at indexPath: IndexPath) -> CGFloat
  
  func horizontalItemSpacingForLayout(_ layout: InputFormLayout) -> CGFloat
  
  func topContentInsetForLayout(_ layout: InputFormLayout) -> CGFloat
  
  func clustersForLayout(_ layout: InputFormLayout) -> [Group]

}

extension InputFormLayoutDataSource {
  
  func inputFormLayout(_ layout: InputFormLayout,
                       isFieldHiddenAt indexPath: IndexPath) -> Bool {
    false
  }

  func verticalItemSpacingForLayout(_ layout: InputFormLayout, at indexPath: IndexPath) -> CGFloat {
    .zero
  }
  
  func horizontalItemSpacingForLayout(_ layout: InputFormLayout) -> CGFloat {
    .zero
  }
  
  func inputFormLayout(_ layout: InputFormLayout,
                       validationErrorViewHeightAt indexPath: IndexPath) -> CGFloat {
    .zero
  }

  
  func topContentInsetForLayout(_ layout: InputFormLayout) -> CGFloat {
    .zero
  }
  
  func clustersForLayout(_ layout: InputFormLayout) -> [Group] {
    []
  }
  
}

final class InputFormLayout: UICollectionViewLayout {
  
  static let validationErrorViewKind = "validationErrorView"
  
  var contentInset = UIEdgeInsets.zero
 
  var contentWidth: CGFloat {
    (collectionView?.width ?? 320.0) - contentInset.left - contentInset.right
  }
  
  weak var dataSource: InputFormLayoutDataSource!
  
  private var attributes = [UICollectionViewLayoutAttributes()]

  override func prepare() {
    let itemCount = collectionView!.numberOfItems(inSection: 0)
    
    let clusters = dataSource.clustersForLayout(self)
    
    var offset: CGFloat = dataSource.topContentInsetForLayout(self)
    
    var positionInCurrentCluster = 0
    
    var validationErrorViewInCurrentClusterHeight: CGFloat = .zero
    
    for i in 0..<itemCount {
      let isFieldHidden = dataSource.inputFormLayout(self, isFieldHiddenAt: .init(item: i, section: 0))
      
      let containingCluster = clusters
        .filter { $0.contains(i) }
        .first
      
      let clusterLength: Int
      let isEndOfCluster: Bool
      if let cluster = containingCluster {
        positionInCurrentCluster = i - cluster.location
        clusterLength = cluster.length
        isEndOfCluster = cluster.location + cluster.length - 1 == i
      } else {
        positionInCurrentCluster = 0
        clusterLength = 1
        isEndOfCluster = true
      }
      
      let hSpacing = dataSource.horizontalItemSpacingForLayout(self)
            
      let contentWidth = (collectionView?.width ?? 320.0) - contentInset.left - contentInset.right
      let itemWidth = (contentWidth - (CGFloat(clusterLength) - 1) * hSpacing) / CGFloat(clusterLength)
      
      let xPosition = contentInset.left + CGFloat(positionInCurrentCluster) * (itemWidth + hSpacing)
      
      let indexPath = IndexPath(item: i, section: 0)
      var height = dataSource.inputFormLayout(self, itemHeightAt: indexPath)
      if isFieldHidden {
        height = .zero
      }
      let validationErrorViewHeight = dataSource.inputFormLayout(self, validationErrorViewHeightAt: indexPath)
      validationErrorViewInCurrentClusterHeight = max(validationErrorViewInCurrentClusterHeight, validationErrorViewHeight)
      
      with(UICollectionViewLayoutAttributes(forCellWith: indexPath)) {
        $0.frame = .init(x: xPosition, y: offset, width: itemWidth, height: height)
        if height == .zero {
          $0.alpha = .zero
          $0.transform = .init(translationX: .zero, y: -10.0)
        }
        attributes.append($0)
      }
      
      with(UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: InputFormLayout.validationErrorViewKind,
                                            with: indexPath)) {
        $0.frame = .init(
          x: xPosition,
          y: offset + height,
          width: itemWidth,
          height: validationErrorViewHeight)
        attributes.append($0)
      }
      
      let needsAddSpacing = height > 0
      let heightIncrement = needsAddSpacing
        ? dataSource.verticalItemSpacingForLayout(self, at: .init(item: i, section: 0))
        : .zero
      
      
      if isEndOfCluster {
        offset += height + heightIncrement + validationErrorViewInCurrentClusterHeight
        validationErrorViewInCurrentClusterHeight = .zero
      }
    }
  }
  
  override func invalidateLayout() {
    attributes = []
  }
  
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    attributes.filter { $0.indexPath == indexPath }.first
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    attributes
  }
  
  override var collectionViewContentSize: CGSize {
    return .init(width: collectionView?.width ?? .zero,
          height: attributes.last?.frame.maxY ?? .zero)
  }
    
}

//
//  InputFormCollectionAdapter.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 15.02.2021.
//

import UIKit

final class InputFormCollectionAdapter: NSObject {
  
  private let form: InputForm
  private let collectionView: UICollectionView
  private var behaviors = [CollectionViewBehavior]()
  private var validationErrorViewType: UICollectionReusableView.Type?
  private var decorators = [String: (UICollectionViewCell) -> Void]()
  var spacingController: CellSpacingProviding = CellSpacingController()
  
  private var layout: InputFormLayout! {
    collectionView.collectionViewLayout as? InputFormLayout
  }
  
  private var cellMatcherMap = [String: () -> UICollectionViewCell.Type]()
  private var cellPrototypes = [String: UICollectionViewCell]()
  
  init(form: InputForm, collectionView: UICollectionView) {
    self.form = form
    self.collectionView = collectionView

    super.init()
    
    self.layout.dataSource = self
  }
  
  func registerCellType(_ cellType: UICollectionViewCell.Type,
                        for fieldType: InputField.Type) {
    cellMatcherMap[String(describing: fieldType)] = { cellType }
    collectionView.registerCellClass(cellType)
    cellPrototypes[cellType.reuseIdentifier] = cellType.init(frame: .zero)
  }
  
  func registerBehaviors(_ behaviors: [CollectionViewBehavior]) {
    behaviors.forEach { $0.collectionView = collectionView }
    self.behaviors += behaviors
  }
  
  func registerValidationErrorViewType(_ type: UICollectionReusableView.Type) {
    validationErrorViewType = type
    collectionView.register(ValidationErrorView.self,
                            forSupplementaryViewOfKind: InputFormLayout.validationErrorViewKind,
                            withReuseIdentifier: type.reuseIdentifier)
  }
  
  func updateErrorMessages(at indexPath: IndexPath) {
    collectionView
      .visibleSupplementaryViews(ofKind: InputFormLayout.validationErrorViewKind)
      .compactMap { $0 as? ValidationErrorView }
      .filter { $0.fieldId == form.field(at: indexPath).uid }
      .first?
      .display(form.validationErrorMessages(at: indexPath))
  }
  
  func decorateCell<T: UICollectionViewCell>(_ type: T.Type, decorator: @escaping (T) -> Void) {
    decorators[type.reuseIdentifier] = {
      decorator($0 as! T)
    }
  }
  
  private var customSpacings = [String: CGFloat]()
  
  func setCustomTrailingSpacing<T: UICollectionViewCell>(_ spacing: CGFloat, for cellType: T.Type) {
    customSpacings[cellType.reuseIdentifier] = spacing
  }
  
}

extension InputFormCollectionAdapter: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView,
                      willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    behaviors.forEach {
      $0.collectionView?(collectionView,
                         willDisplay: cell,
                         forItemAt: indexPath)
    }
  }
  
}

extension InputFormCollectionAdapter: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    form.fields.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let identifier = cellType(forItemAt: indexPath).reuseIdentifier
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                  for: indexPath)
    
    decorators[cell.reuseIdentifier!]?(cell)

    (cell as? InputFieldDisplaying)?.display(form.field(at: indexPath))
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: validationErrorViewType!.reuseIdentifier,
      for: indexPath)
    
    (view as! ValidationErrorView).display(form.validationErrorMessages(at: indexPath))
    (view as! ValidationErrorView).fieldId = form.field(at: indexPath).uid
    
    return view
  }
  
}

extension InputFormCollectionAdapter: InputFormLayoutDataSource {
  
  func inputFormLayout(_ layout: InputFormLayout,
                       itemHeightAt indexPath: IndexPath) -> CGFloat {
    let prototype = cellPrototype(forItemAt: indexPath)
    (prototype as? InputFieldDisplaying)?.display(form.field(at: indexPath))
    prototype.prepareForReuse()

    return (prototype as? HeightCalculating)?
      .height(atWidth: collectionView.width)
      ?? .zero
  }
  
  func verticalItemSpacingForLayout(_ layout: InputFormLayout, at indexPath: IndexPath) -> CGFloat {
    let nextIndex = indexPath.item + 1
    guard form.fields.lastIndex >= nextIndex else { return .zero }
    
    let nextIndexPath = IndexPath(item: nextIndex, section: 0)
    
    
    
    let identifier = cellType(forItemAt: indexPath).reuseIdentifier
    let nextIdentifier = cellType(forItemAt: nextIndexPath).reuseIdentifier
    
    return spacingController.spacingBetween(identifier, and: nextIdentifier)
  }
  
  func horizontalItemSpacingForLayout(_ layout: InputFormLayout) -> CGFloat {
    20.0
  }
  
  func topContentInsetForLayout(_ layout: InputFormLayout) -> CGFloat {
    20.0
  }
  
  func inputFormLayout(_ layout: InputFormLayout, isFieldHiddenAt indexPath: IndexPath) -> Bool {
    let field = form.field(at: indexPath)
    return form.hiddenFields.contains(field)
  }
  
  func inputFormLayout(_ layout: InputFormLayout,
                       validationErrorViewHeightAt indexPath: IndexPath) -> CGFloat {
    let messages = form.validationErrorMessages(at: indexPath).filter( { !$0.isEmpty })
    
    guard !messages.isEmpty else { return .zero }
    
    let view = ValidationErrorView(frame: .zero)
    view.display(messages)
    
    return view.systemLayoutSizeFitting(
      .init(
        width: layout.contentWidth,
        height: .zero),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel).height
  }
  
  func clustersForLayout(_ layout: InputFormLayout) -> [Group] {
    form.clusters()
  }
  
}

private extension InputFormCollectionAdapter {
  
  func cellType(forItemAt indexPath: IndexPath) -> UICollectionViewCell.Type {
    let field = form.field(at: indexPath)
    let key = String(describing: type(of: field))

    return cellMatcherMap[key]!()
  }
  
  func cellPrototype(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
    cellPrototypes[cellType(forItemAt: indexPath).reuseIdentifier]!
  }
  
}

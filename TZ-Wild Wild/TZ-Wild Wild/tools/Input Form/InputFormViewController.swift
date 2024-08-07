//
//  InputFormViewController.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 15.02.2021.
//

import UIKit

class InputFormViewController: UIViewController {
  
  var layout: InputFormLayout {
    collectionView.collectionViewLayout as! InputFormLayout
  }
  
  let form: InputForm
  
  var cellSpacingController: CellSpacingProviding {
    get { adapter.spacingController }
    set { adapter.spacingController = newValue }
  }
  
  private let adapter: InputFormCollectionAdapter
  
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: InputFormLayout())
  
  init(form: InputForm) {
    self.form = form
    adapter = .init(form: form, collectionView: collectionView)
    
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    registerCells()
    registerErrorViewType()
    adapter.registerBehaviors(requiredBehaviors())
    subscribeForFormUpdates()
  }
  
  func registerCellType(_ type: UICollectionViewCell.Type,
                        for fieldType: InputField.Type) {
    adapter.registerCellType(type, for: fieldType)
  }
  
  func registerCells() {
    fatalError()
  }
  
  func requiredBehaviors() -> [CollectionViewBehavior] {
    fatalError()
  }
  
  func errorViewType() -> UICollectionReusableView.Type {
    ValidationErrorView.self
  }
  
  func decorateCell<T: UICollectionViewCell>(_ type: T.Type,
                                             decorator: @escaping (T) -> Void) {
    adapter.decorateCell(type, decorator: decorator)
  }
  
  
  func setCustomTrailingSpacing<T: UICollectionViewCell>(_ spacing: CGFloat,
                                                         for cellType: T.Type) {
    adapter.setCustomTrailingSpacing(spacing, for: cellType)
  }
  
}

private extension InputFormViewController {
  
  func setup() {
    with(collectionView) {
      $0.delegate = adapter
      $0.dataSource = adapter
    }.add(to: view)
    .constrainEdgesToSuperview()
  }
  
  func subscribeForFormUpdates() {
    form.didEndEditing.observe { [weak self] in
      self?.view.endEditing(true)
    }.owned(by: self)
    
    form.didReceiveFocusAtIndex.observe { [weak self] index in
      self?.collectionView.scrollToItem(
        at: .init(item: index, section: 0),
        at: .bottom,
        animated: true)
    }.owned(by: self)
    
    form.needsErrorMessageUpdate.observe { [weak self] indexPath in
      self?.adapter.updateErrorMessages(at: indexPath)
      self?.collectionView.performBatchUpdates({
        self?.layout.invalidateLayout()
      }, completion: nil)
    }.owned(by: self)
    
    form.didUpdateHiddenFields.observe { [weak self] in
      self?.collectionView.performBatchUpdates({
        self?.layout.invalidateLayout()
      }, completion: nil)
    }.owned(by: self)
  }
  
  func registerErrorViewType() {
    adapter.registerValidationErrorViewType(errorViewType())
  }
  
}

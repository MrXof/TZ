//
//  BigButtonCell.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 16.02.2021.
//

import UIKit

final class BigButtonCell: UICollectionViewCell {

  private let actionButton = PrimaryButton()
  private var field: BigActionField?
  private var subscriptionForEnabledState: Subscription?

  override func prepareForReuse() {
    super.prepareForReuse()

    subscriptionForEnabledState?.dispose()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

}

extension BigButtonCell: InputFieldDisplaying {
  
  func display(_ field: InputField) {
    guard let field = field as? BigActionField else { return }
    
    self.field = field
    actionButton.title = field.actionTitle
    subscriptionForEnabledState = field.isEnabled
      .observe { [weak self] isEnabled in
        UIView.animate(withDuration: 0.1) { [weak self] in
          self?.actionButton.isActionEnabled = isEnabled
        }
      }
      .owned(by: self)
  }
  
}

private extension BigButtonCell {

  func setup() {
    with(actionButton) {
      $0.addTouchAction { [weak self] in
        self?.field?.invokeActionAccordingToState()
      }
    }
    .add(to: contentView)
    .constrainEdgesToSuperview()
  }

}

extension BigButtonCell: HeightCalculating {}

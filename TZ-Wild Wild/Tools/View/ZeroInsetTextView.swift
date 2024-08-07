//
//  ZeroInsetTextView.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 31.12.2020.
//

import UIKit

class ZeroInsetTextView: UITextView {
   
  override func layoutSubviews() {
    super.layoutSubviews()
    
    textContainerInset.left = .zero
    textContainerInset.right = .zero
    textContainer.lineFragmentPadding = 0
   }
  
}

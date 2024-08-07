//
//  OptionPickerField.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 22.04.2021.
//

import Foundation

struct ChoiceOption: Equatable {

  let uid: String
  let title: String
  
  static func ==(lhs: ChoiceOption, rhs: ChoiceOption) -> Bool {
    lhs.uid == rhs.uid
  }
  
}

final class OptionPickerField: InputField {
  
  let selectedOption: Observable<ChoiceOption>
  let options: [ChoiceOption]
  
  init(options: [ChoiceOption]) {
    self.options = options
    selectedOption = .init(options.first!)
  }
  
  func selectOption(_ option: ChoiceOption) {
    selectedOption.value = option
  }
  
}

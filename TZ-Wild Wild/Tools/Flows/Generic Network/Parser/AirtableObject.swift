//
//  AirtableObject.swift
//  OneCourt
//
//  Created by Oleksii Chernysh on 02.07.2021.
//

import Foundation

protocol AirtableObject {
  
  init(json: JSON) throws
  
}

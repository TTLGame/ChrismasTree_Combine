//
//  ValidationModel.swift
//  LongTester
//
//  Created by Long on 6/7/23.
//

import Foundation

final class ValidationModel: Model {
    var regex: String
    var errorMessage: String
    
    init(regex: String, errorMessage: String) {
        self.regex = regex
        self.errorMessage = errorMessage
    }
}

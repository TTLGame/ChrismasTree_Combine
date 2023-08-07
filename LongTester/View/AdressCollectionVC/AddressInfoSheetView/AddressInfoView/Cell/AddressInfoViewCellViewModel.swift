//
//  AddressInfoViewCellViewModel.swift
//  LongTester
//
//  Created by Long on 5/19/23.
//

import Foundation

class AddressInfoViewCellViewModel {
    let title : String?
    let value : String?
    let shouldHighlightTitle : Bool?
    let shouldHighlightValue : Bool?
    init(title: String?, value: String?,shouldHighlightTitle : Bool = false , shouldHighlightValue : Bool = false) {
        self.title = title
        self.value = value
        self.shouldHighlightTitle = shouldHighlightTitle
        self.shouldHighlightValue = shouldHighlightValue
    }
}

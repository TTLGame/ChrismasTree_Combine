//
//  BaseDropDownCellViewModel.swift
//  LongTester
//
//  Created by Long on 5/17/23.
//

import Foundation

protocol BaseDropDownViewModel {
    var title : String? { get set }
}

class BaseDropDownCellViewModel : BaseDropDownViewModel {
    var title: String?
    init(title: String?) {
        self.title = title
    }
}

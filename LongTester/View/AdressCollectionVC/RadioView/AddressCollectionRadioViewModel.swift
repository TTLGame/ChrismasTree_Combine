//
//  AddressCollectionRadioViewModel.swift
//  LongTester
//
//  Created by Long on 5/16/23.
//

import Foundation

class AddressCollectionRadioViewModel {
    var cellViewModels : [AddressCollectionRadioViewCellViewModel]?
    init(cellViewModels: [AddressCollectionRadioViewCellViewModel]?) {
        self.cellViewModels = cellViewModels
    }
}

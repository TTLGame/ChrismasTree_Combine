//
//  AddressCollectionMonthYearViewModel.swift
//  LongTester
//
//  Created by Long on 5/23/23.
//

import Foundation

class AddressCollectionMonthYearViewModel {
    var monthYear : MonthYear
    var cellViewModels :  [AddressCollectionViewCellViewModel]
    init(monthYear: MonthYear, cellViewModels: [AddressCollectionViewCellViewModel]) {
        self.monthYear = monthYear
        self.cellViewModels = cellViewModels
    }
    init() {
        self.monthYear = MonthYear()
        self.cellViewModels = []
    }
}

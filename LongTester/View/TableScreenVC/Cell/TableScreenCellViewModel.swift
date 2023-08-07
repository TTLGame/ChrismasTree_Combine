//
//  TableScreenCellViewModel.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation

class TableScreenCellViewModel {
    let avatar: String?
    let fullName: String?
    init(avatar: String?,
         fullName: String?) {
        self.avatar = avatar
        self.fullName = fullName
    }
}

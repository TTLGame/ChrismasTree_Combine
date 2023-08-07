//
//  AddressCollectionViewCellViewModel.swift
//  LongTester
//
//  Created by Long on 4/22/23.
//

import Foundation

class AddressCollectionViewCellViewModel {
    enum roomStatus : String {
        case paid = "Paid"
        case notPaid = "NotPaid"
        case pending = "Pending"
        case vacancy = "Vacancy"
    }
    let id : String?
    let roomNums : Int?
    let renters : Int?
    let status : String?
    let waterNum : Int?
    let lastWaterNum : Int?
    
    let electricNum : Int?
    let lastElectricNum : Int?
    
    let totalNum : Int?
    init(id: String?, roomNums: Int?, renters: Int?, status: String?, waterNum: Int?, lastWaterNum: Int?, electricNum: Int?, lastElectricNum: Int?, totalNum: Int?) {
        self.id = id
        self.roomNums = roomNums
        self.renters = renters
        self.status = status
        self.waterNum = waterNum
        self.lastWaterNum = lastWaterNum
        self.electricNum = electricNum
        self.lastElectricNum = lastElectricNum
        self.totalNum = totalNum
    }
}

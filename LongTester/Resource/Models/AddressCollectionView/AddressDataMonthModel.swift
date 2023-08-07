//
//  AddressDataMonthModel.swift
//  LongTester
//
//  Created by Long on 5/24/23.
//

import Foundation

class AddressDataMonthModel : Codable, Model {
    var monthYear : String?
    var globalElectric : Int?
    var globalWater : Int?
    var globalQuotaPrice : Int?
    var globalQuota : Int?
    var globalRoomPrice : Int?
    var roomData :  [RoomDataModel]?
    
    init() { }

    init(monthYear: String? = nil, globalElectric: Int? = nil, globalWater: Int? = nil, globalQuotaPrice: Int? = nil, globalQuota: Int? = nil, globalRoomPrice: Int? = nil, roomData: [RoomDataModel]? = nil) {
        self.monthYear = monthYear
        self.globalElectric = globalElectric
        self.globalWater = globalWater
        self.globalQuotaPrice = globalQuotaPrice
        self.globalQuota = globalQuota
        self.globalRoomPrice = globalRoomPrice
        self.roomData = roomData
    }
}

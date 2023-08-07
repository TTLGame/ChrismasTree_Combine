//
//  AddressDataReqModel.swift
//  LongTester
//
//  Created by Long on 6/5/23.
//

import Foundation

public class RoomDataReqModel : Codable, Model {
    var monthYear: String?
    var roomData : [RoomDataModel]?
    
    init() { }
    
    init(monthYear: String? = nil, roomData: [RoomDataModel]? = nil) {
        self.monthYear = monthYear
        self.roomData = roomData
    }
}
//public class RoomDataReqModel{
//
//}

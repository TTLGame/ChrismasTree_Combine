//
//  MainScreenAddMorePopUpViewModel.swift
//  LongTester
//
//  Created by Long on 6/4/23.
//

import Foundation

class MainScreenAddMorePopUpViewModel : Model{
    var inputName : String
    var inputAddress : String
    var inputRooms : Int
    var inputQuota : Int
    var inputQuotaPrice : Int
    var inputWater : Int
    var inputElectric : Int
    var inputRoomPrice : Int
    init(inputName : String = "",
         inputAddress: String = "",
         inputRooms: Int = 0,
         inputQuota: Int = 0,
         inputQuotaPrice: Int = 0,
         inputWater: Int = 0,
         inputElectric: Int = 0,
         inputRoomPrice: Int = 0) {
        self.inputName = inputName
        self.inputAddress = inputAddress
        self.inputRooms = inputRooms
        self.inputQuota = inputQuota
        self.inputQuotaPrice = inputQuotaPrice
        self.inputWater = inputWater
        self.inputElectric = inputElectric
        self.inputRoomPrice = inputRoomPrice
    }
    
    func checkValidation() -> Bool {
        return
            inputAddress != "" &&
            inputRooms != 0 &&
            inputWater != 0 &&
            inputElectric != 0 &&
            inputRoomPrice != 0
    }
}

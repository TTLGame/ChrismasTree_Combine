//
//  MainViewModel.swift
//  LongTester
//
//  Created by Long on 6/4/23.
//

import Foundation


final class MainViewModel : Codable, Model {
    var statusCode : Int?
    var messageVN : String?
    var messageEN : String?
    var data : [MainViewDataModel]?
    init() { }
}

final class MainViewDataModel : Codable, Model {
    var id : String?
    var name : String?
    var address : String?
    var globalPrice : Int?
    var currentRooms : Int?
    var totalRooms : Int?
    
    init() { }
    
    init(id: String? = nil, name: String? = nil, address: String? = nil, globalPrice: Int? = nil, currentRooms: Int? = nil, totalRooms: Int? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.globalPrice = globalPrice
        self.currentRooms = currentRooms
        self.totalRooms = totalRooms
    }}

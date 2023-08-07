//
//  MainScreenCellViewModel.swift
//  LongTester
//
//  Created by Long on 4/20/23.
//

import Foundation
import UIKit

enum backbroundType : String, CaseIterable {
    case pyramid = "PyramidBG"
    case nature = "NatureBG"
    case ship = "ShipBG"
    case snow = "SnowBG"
    case beach = "BeachBG"
    var fontColor : UIColor {
        switch self {
        case .nature, .ship, .pyramid, .snow:
            return .white
        case .beach:
            return Color.greyPrimary
        }
    }
    
    var roomFontColor : UIColor {
        switch self {
        case .nature, .ship, .pyramid, .snow:
            return Color.orangePrimary
        case .beach:
            return Color.redPrimary
        }
    }
    
}
class MainScreenCellViewModel {
    let logo: String?
    let background: backbroundType?
    let name : String?
    let address : String?
    let globalPrice : Int?
    let currentRooms : Int?
    let totalRooms : Int?
    init(logo: String?,
         background: backbroundType?,
         name : String?,
         address : String?,
         globalPrice : Int?,
         currentRooms : Int?,
         totalRooms : Int?){
        self.logo = logo
        self.background = background
        self.name = name
        self.address = address
        self.globalPrice = globalPrice
        self.currentRooms = currentRooms
        self.totalRooms = totalRooms
    }
}

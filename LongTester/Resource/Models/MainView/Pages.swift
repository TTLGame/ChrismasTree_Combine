//
//  Pages.swift
//  LongTester
//
//  Created by Long on 4/18/23.
//

import Foundation

final class Pages : Codable, Model {
    
    var page : Int?
    var per_page : Int?
    var total : Int?
    var total_pages : Int?
    var data : [User]?
    init() { }
}


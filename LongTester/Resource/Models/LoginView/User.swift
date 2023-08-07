//
//  User.swift
//  LongTester
//
//  Created by Long on 1/3/23.
//

import Foundation
import RealmSwift

final class User : Codable, Model {
    var id : String?
    var email : String?
    var fullname : String?
    var phone : String?
    var dob : String?
    var avatar : String?
    init() { }
    
}


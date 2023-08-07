//
//  LoginModel.swift
//  LongTester
//
//  Created by Long on 6/3/23.
//

import Foundation
import RealmSwift

final class LoginModel : Codable, Model {
    var statusCode : Int?
    var data : LoginDataModel?
    var message : String?
    init() { }
}

final class LoginDataModel : Codable, Model {
    var user : User?
    var token : String?
    init() { }
    
}

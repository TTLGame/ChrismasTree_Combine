//
//  RegisterModel.swift
//  LongTester
//
//  Created by Long on 6/7/23.
//

import Foundation

public class RegisterReqModel : Codable, Model {
    var email : String?
    var password : String?
    var fullname : String?
    var dob : String?
    var gender : Bool?
    var phone : String?
    init() {}
    init(email: String? = nil, password: String? = nil, fullname: String? = nil, dob: String? = nil, gender: Bool? = nil, phone: String? = nil) {
        self.email = email
        self.password = password
        self.fullname = fullname
        self.dob = dob
        self.gender = gender
        self.phone = phone
    }
}

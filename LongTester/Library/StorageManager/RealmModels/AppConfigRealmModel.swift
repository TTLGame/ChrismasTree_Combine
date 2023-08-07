//
//  AppConfigRealmModel.swift
//  LongTester
//
//  Created by Long on 4/18/23.
//

import Foundation
import RealmSwift

class AppConfigRealmModel: Object, RealmCollectionModels {
    @objc dynamic var id : String = ""
    @objc dynamic var json : String = ""
    @objc dynamic var type_collection : String = ""
    
    convenience init (id: String, json: String, type_collection: String) {
        self.init()
        self.id = id
        self.json = json
        self.type_collection = type_collection
    }
}

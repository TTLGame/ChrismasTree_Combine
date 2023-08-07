//
//  RealmCollectionModels.swift
//  LongTester
//
//  Created by Long on 4/18/23.
//

import Foundation

import RealmSwift
protocol RealmCollectionModels: Object, AnyObject, Codable  {
    dynamic var json : String { get set }
    dynamic var type_collection : String { get set }
    
}

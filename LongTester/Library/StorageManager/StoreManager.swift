//
//  StoreManager.swift
//  LongTester
//
//  Created by Long on 4/18/23.
//

import Foundation
import RealmSwift
final class StoreManager {
    ///INIT REALM
    
    var realm : Realm!
//    let key = " O0GZJ9shekV0raY80sa3P5QjL5tuU87VlRwhxt9hwO1Q2k3euq60z5ktpOg86Nn"
    
    init() {
        
    #if DEBUG
        print("[Realm Path] - \(Realm.Configuration.defaultConfiguration.fileURL!)")
        initDebug()
    #else
        initRelease()
    #endif
        
    }
    private func initDebug(){
        let databaseUrl = Realm.Configuration.defaultConfiguration.fileURL!
        print("[Realm-DEBUG] - Get Encription Key")
        do {
            let tempRealm = try Realm()
            realm = tempRealm
        }
        catch {
            print("[Realm-DEBUG] - Remove DB")
            removeDatabase(realmURL: databaseUrl)
            let tempRealm = try! Realm()
            realm = tempRealm
        }
    }
    
    private func initRelease(){
        let databaseUrl = Realm.Configuration.defaultConfiguration.fileURL!
        var key = Data(count: 64)
        _ = key.withUnsafeMutableBytes {
           SecRandomCopyBytes(kSecRandomDefault, 64, $0.baseAddress!)
       }

       //Check if encript Key is on UserDefault
       if let storeKey = UserDefaults.standard.value(forKey: "realmKey") as? Data {
           print("[Realm] - Get Encription Key")
           key = storeKey
       }
       else {
           print("[Realm] - Save Encription Key")
           UserDefaults.standard.set(key, forKey: "realmKey")
       }
        let config = Realm.Configuration(encryptionKey: key)
        do {
            let tempRealm = try Realm(configuration: config)
            realm = tempRealm
        }
        catch {
            print("[Realm] - Remove DB")
            removeDatabase(realmURL: databaseUrl)
            let tempRealm = try! Realm(configuration: config)
            realm = tempRealm
        }
    }
    
    static let shared: StoreManager = {
        let instance = StoreManager()
        return instance
    }()
    
    
    
    enum CollectionName: String, CaseIterable {
        case appConfig  = "AppConfig"
        case user = "User"
        var searchFields: [String] {
            switch self {
            case .appConfig, .user : return ["id"]
            }
        }
        
        var fieldModels : RealmCollectionModels.Type {
            switch self {
            case .appConfig, .user : return AppConfigRealmModel.self
            }
        }
    }

    private func initCollection(data: JSObject, in collectionName: CollectionName) -> RealmCollectionModels {
        let converted = compactMapForDict(data: data)
        let stringJSON = data.convertDict()
//        let converted = data
        switch collectionName.fieldModels {
        case is AppConfigRealmModel.Type:
            return AppConfigRealmModel(id: converted["id"] as? String ?? "",
                                          json: stringJSON,
                                          type_collection: collectionName.rawValue)
        
        default:
            break
        }
        return AppConfigRealmModel(id: converted["id"] as? String ?? "",
                                   json: stringJSON,
                                   type_collection: collectionName.rawValue)
    }

    private func compactMapForDict(data : JSObject) -> JSObject{
        return data.compactMapValues {
            let checkData = $0 as? String
            if (checkData != nil) {
                return checkData
            }
            else {
                return $0
            }
        }
    }

    func find(queryParts: [String: Any], in collectionName: CollectionName) -> [JSObject]? {
        let queryValue : String = getQueryFilter(queryParts: queryParts, in: collectionName)
        let data = realm.objects(collectionName.fieldModels.self).filter(queryValue).toArray(ofType: collectionName.fieldModels.self)
        
        let convertedData = data.map {
            let data = $0 as! RealmCollectionModels
            var dic : JSObject = [:]
            do {
                dic = try data.asDictionary()
            } catch {
                print("error")
            }
            return dic
        }
        return convertedData
    }
    
    func getQueryFilter(queryParts: [String: Any], in collectionName: CollectionName) -> String {
        var queryValue : String = "type_collection == \"\(collectionName.rawValue)\""
        for (key,value) in queryParts {
            queryValue += queryValue.isEmpty ? "" : " AND "
            queryValue += key + " == " + "\"\(value)\""
        }
        return queryValue
    }

    @discardableResult
    func clear(collectionName: CollectionName) -> Bool {
        let dataFilters = realm.objects(collectionName.fieldModels.self)
        try! realm.write {
            realm.delete(dataFilters)
            print("----------- REALM clear data \(collectionName.rawValue)")
        }
        return true
    }

    func exits(by field: String, equal value: String, in collectionName: CollectionName) -> Bool {
        let obj = realm.objects(collectionName.fieldModels.self)
            .filter("\(field) == %@",value)
        return obj.count > 0
    }
}

//MARK: FUNCTION CAN ACCESS THROUGHOUT SINGLETON
extension StoreManager {
    func save(data: JSObject, in collectionName: CollectionName) throws {
        var queryValue : String = "type_collection == \"\(collectionName.rawValue)\""
        for searchField in collectionName.searchFields {
            if let id = data[searchField] as? String {
                queryValue += queryValue.isEmpty ? "" : " AND "
                queryValue += searchField + " == " + "\"\(id)\""
            } else if let id = (data[searchField] as? Int) {
                queryValue += queryValue.isEmpty ? "" : " AND "
                queryValue += searchField + " == " + "\"\(String(id))\""
            }
        }
        let fieldModel = collectionName.fieldModels.self
        if !queryValue.isEmpty {
            if let obj = self.realm.objects(fieldModel)
                .filter(queryValue)
                .toArray(ofType: fieldModel).first as? RealmCollectionModels {
                try! self.realm.write {
                    let converted = data.convertDict()
                    obj.json = converted
                    //                    obj.json = data.description
                }  // Update Exits Models
            } else {
                let model = self.initCollection(data: data, in: collectionName)
                
                try! self.realm.write {
                    self.realm.add(model)
                }  // ADD New Models
            }
        } else {
            let model = self.initCollection(data: data, in: collectionName)
            
            try! self.realm.write {
                self.realm.add(model)
            }
        }
    }
    
    @discardableResult
    func remove(queryParts: [String: Any], in collectionName: CollectionName) -> Bool {
        let queryValue : String = getQueryFilter(queryParts: queryParts, in: collectionName)
        
        let dataFilters = realm.objects(collectionName.fieldModels.self)
            .filter(queryValue)
        try! realm.write {
            realm.delete(dataFilters)
        }
        return true
    }
    
    ///FIND DATA : 2 OPTION FOR QUERYING  DATA
    ///DATA <T> -> Models: FIND DATA VIA MODELS
    ///DATA<T> FIND DATA VIA DICTIONARY
    func find<T>(_ clsName: T.Type, queryParts: [String : Any] = [:], in collectionName: CollectionName) -> [T]? {
        
        let results = find(queryParts: queryParts, in: collectionName)
        if (T.self is [String : Any].Type || T.self is JSObject.Type){
            let arr = results?.map {
                let jsonObject = $0["json"] as? String
                var jsonObjectDict = jsonObject?.convertStringToDictionary()
                jsonObjectDict = compactMapForDict(data: jsonObjectDict ?? [:])
                return jsonObjectDict as? T
            }
            return arr?.compactMap({ $0 })
        }
        return results?.compactMap { $0["json"] as? T }
    }
    
    func find<T>(_ clsName: T.Type, queryParts: [String : Any] = [:], in collectionName: CollectionName) -> [T]? where T: Model {
        let results = find(queryParts: queryParts, in: collectionName)
        let arr = results?.map {
            let jsonObject = $0["json"] as? String
            
            var jsonObjectDict = jsonObject?.convertStringToDictionary()
            jsonObjectDict = compactMapForDict(data: jsonObjectDict ?? [:])
            return T(json: jsonObjectDict)
        }
        return arr?.compactMap({ $0 })
    }
    
    func removeDatabase(realmURL: URL) {
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management"),
        ]
        for URL in realmURLs {
            try? FileManager.default.removeItem(at: URL)
        }
    }
}

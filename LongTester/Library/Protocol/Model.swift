//
//  Model.swift
//  LongTester
//
//  Created by Long on 1/3/23.
//

import Foundation

typealias JSObject = [String: Any]
typealias JSArray = [JSObject]

protocol Model: Codable {
    func data(encodingKey: JSONEncoder.KeyEncodingStrategy) -> Data?
    func json(encodingKey: JSONEncoder.KeyEncodingStrategy) -> JSObject?
    init?(result: ResultNew<JSObject>?)
    init?(data: Data?)
    init?(json: JSObject?)

    static func mapToArray(result: ResultNew<JSObject>?) -> [Self]?
}

extension Model where Self: Codable {
    static var encoderCamelKey: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }

    static var encoderSnakeKey: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func data(encodingKey: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) -> Data? {
        switch encodingKey {
        case .useDefaultKeys:
            return try? Self.encoderCamelKey.encode(self)
        case .convertToSnakeCase:
            return try? Self.encoderSnakeKey.encode(self)
        default:
            return nil
        }
    }

    func json(encodingKey: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) -> JSObject? {
        guard let data = self.data(encodingKey: encodingKey),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSObject
            else { return nil }
        return jsonObject
    }

    init?(data: Data?) {
        guard let data = data else { return nil }
        do {
            let anInstance = try Self.decoder.decode(Self.self, from: data)
            self = anInstance
        } catch {
            return nil
        }
    }

    init?(result: ResultNew<JSObject>?) {
        let json = result?.dataJson(type: JSObject.self)
        self.init(data: json?.jsonData())
    }

    init?(json: JSObject?) {
        self.init(data: json?.jsonData())
    }

    static func mapToArray(result: ResultNew<JSObject>?) -> [Self]? {
        //print(result)
        let dataJson = result?.dataJson(type: JSArray.self)
        return Self.mapToArray(jsArray: dataJson)
    }

    static func mapToArray(jsArray: JSArray?) -> [Self]? {
        guard let data = jsArray?.data() else { return nil }
        do {
            let anInstance = try Self.decoder.decode([Self].self, from: data)
            return anInstance
        } catch {
            return nil
        }
    }

    static func mapArray(jsArray: JSArray?) -> [Self]? {
        guard let data = jsArray?.data() else { return nil }
        do {
            let anInstance = try JSONDecoder().decode([Self].self, from: data)
            return anInstance
        } catch {
            return nil
        }
    }
}

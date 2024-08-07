//
//  ResponseParser.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 09.02.2021.
//

import Foundation

typealias JSON = Dictionary<String, Any>

extension JSON {
  
  func get<T>(_ key: String) throws -> T {
    if let value = self[key] as? T {
      return value
    }
    
    throw ParserError(message: "by key - \(key). value: \(self[key])")
  }
  
}

struct ResponseParser<T> {
  fileprivate var parser: (Data) throws -> T
  
  func parse(data: Data) throws -> T {
    try parser(data)
  }
}

extension ResponseParser {
  
  static func custom<T>(_ parser: @escaping (Data) throws -> T) -> ResponseParser<T> {
    ResponseParser<T>(parser: parser)
  }
  
}

extension ResponseParser where T: AirtableObject {
  
  static var collection: ResponseParser<[T]> {
    ResponseParser<[T]> {
      do {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone, .withFractionalSeconds]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
          let container = try decoder.singleValueContainer()
                  let dateStr = try container.decode(String.self)
          let date = formatter.date(from: dateStr)
          guard let d = date else {
            throw ParserError(message: "date from \(dateStr)")
          }
          return d
        }
        let json = try ResponseParser.rawDictionary.parse(data: $0)
        let records: [JSON] = json["records"]! as! [JSON]
        
        let recordContents: [JSON] = records.map {
          var fields = $0["fields"] as! JSON
          fields["uid"] = $0["id"]
          return fields
        }
//        for recordContent in recordContents {
//          do {
//            let t = try T.init(json: recordContent)
//          }
//          catch {
//            print(error)
//            print(recordContent["name"]!)
//            print()
//          }
//        }
        return try recordContents.map(T.init)
      } catch let error {
        print(error)
        throw error
//        throw ParserError(message: String(describing: T.self))
      }
    }
  }
  
  static var page: ResponseParser<Page<T>> {
    ResponseParser<Page<T>> {
      do {
        let objects: [T] = try ResponseParser.collection.parse(data: $0)
        let offset: String? = try? ResponseParser.field("offset").parse(data: $0)
        
        return .init(offset: offset, objects: objects)
      } catch {
        throw ParserError(message: "page of \(String(describing: T.self))\n\(error)")
      }
    }
  }
  
}

extension ResponseParser where T: Decodable {
  static var `default`: ResponseParser<T> {
    ResponseParser<T> {
      do {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone, .withFractionalSeconds]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
          let container = try decoder.singleValueContainer()
                  let dateStr = try container.decode(String.self)
          let date = formatter.date(from: dateStr)
          guard let d = date else {
            throw ParserError(message: "date from \(dateStr)")
          }
          return d
        }
        let result = try decoder.decode(T.self, from: $0, keyPath: "payload")
        return result
      } catch {
        throw ParserError(message: String(describing: T.self))
      }
    }
  }
}

extension ResponseParser {
  
  static var rawDictionary: ResponseParser<JSON> {
    .init {
      do {
        if let json = try JSONSerialization.jsonObject(
            with: $0,
            options: .mutableContainers) as? JSON {
          return json
        } else {
          throw ParserError(message: "JSON from \(String(data: $0, encoding: .utf8) ?? "")")
        }
      } catch {
        throw ParserError(message: "JSON from \(String(data: $0, encoding: .utf8) ?? "")")
      }
    }
  }
    
  static var binary: ResponseParser<Data> {
    .init(parser: id)
  }
  
  static func field<T>(_ key: String) throws -> ResponseParser<T> {
    return ResponseParser<T> {
      let jsonParser = ResponseParser.rawDictionary
      let json = try jsonParser.parse(data: $0)
      if let result = json[key] as? T {
        return result
      } else {
        throw ParserError(message: "\(String(describing: T.self)) by key \(key)")
      }
    }
  }
  
  static func keyPath<T>(_ keyPath: String...) -> ResponseParser<T> {
    return ResponseParser<T> {
      let jsonParser = ResponseParser.rawDictionary
      var json = try jsonParser.parse(data: $0)
      for key in keyPath {
        if let nextContainer = json[key] as? JSON, key != keyPath.last {
          json = nextContainer
        } else if let result = json[key] as? T {
          return result
        }
      }
      throw ParserError(message: "\(String(describing: T.self)) by keyPath \(keyPath)")
    }
  }
}

struct ParserError: Error, LocalizedError {
  
  let message: String
  
  var errorDescription: String? {
    "Parsing error: \(message)"
  }
  
}

struct ServerConfirmation: Decodable {}

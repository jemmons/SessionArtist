import Foundation
import Medea

public enum Params {
  case form([URLQueryItem]), json(ValidJSONObject)
  
  public init(_ form: [URLQueryItem]) {
    self = .form(form)
  }
  
  
  public init(_ json: ValidJSONObject) {
    self = .json(json)
  }
  
  
  public func makeQuery() -> [URLQueryItem] {
    switch self {
    case .form(let qs):
      return qs
    case .json(let j):
      return Helper.makeQuery(from: j)
    }
  }
  
  
  public func makeData() -> Data {
    switch self {
    case .form(let qs):
      var comp = URLComponents()
      comp.queryItems = qs
      guard let query = comp.query else {
        fatalError("“queryItems” somehow wasn't set.")
      }
      guard let data = query.data(using: .utf8, allowLossyConversion: true) else {
        fatalError("encoding can't fail if lossy is true.")
      }
      return data
    case .json(let j):
      return JSONHelper.data(from: j)
    }
  }
  
  
  public var contentType: [HTTPHeaderField: String] {
    switch self {
    case .form:
      return [.contentType: "application/x-www-form-urlencoded"]
    case .json:
      return [.contentType: "application/json"]
    }
  }
}



private enum Helper {
  static func makeQuery(from json: ValidJSONObject) -> [URLQueryItem] {
    //Assume it won't throw becasue we're enforcing JSONObject type.
    return try! makeQuery(from: json.value, prefix: nil)
  }
  
  /**
   Generalized version to allow for recursion.
   - throws: `JSONError.unexpectedType` if not called (initially) on a JSONObject.
   */
  static private func makeQuery(from jsonValue: Any, prefix: String? = nil) throws -> [URLQueryItem] {
    var items: [URLQueryItem] = []
    
    switch jsonValue {
    case let d as Dictionary<String, Any>:
      try d.forEach {
        let newPrefix = prefix == nil ? $0.key : prefix! + "[\($0.key)]"
        items.append(contentsOf: try makeQuery(from: $0.value, prefix: newPrefix))
      }
      
    case let a as Array<Any>:
      guard let somePrefix = prefix else {
        throw(Medea.JSONError.unexpectedType)
      }
      try a.forEach { it in
        items.append(contentsOf: try makeQuery(from: it, prefix: somePrefix + "[]"))
      }
      
    default:
      guard let somePrefix = prefix else {
        throw(Medea.JSONError.unexpectedType)
      }
      items.append(URLQueryItem(name: somePrefix, value: String(describing: jsonValue)))
    }
    
    return items
  }
}

import Foundation



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
        preconditionFailure("“queryItems” somehow wasn’t set.")
      }
      return Data(query.utf8)
    case .json(let j):
      guard let jsonData = try? JSONSerialization.data(withJSONObject: j.value, options: []) else {
        preconditionFailure("ValidJSONObject wasn’t valid.")
      }
      return jsonData
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
    // Assume it won't throw becasue we're enforcing JSONObject type.
    // swiftlint:disable:next force_try
    return try! makeQuery(from: json.value, prefix: nil)
  }
  
  
  /**
   Generalized version to allow for recursion.
   - throws: `notJSONObject` if not called (initially) on a JSONObject.
   */
  private static func makeQuery(from jsonValue: Any, prefix: String? = nil) throws -> [URLQueryItem] {
    var items: [URLQueryItem] = []
    
    switch jsonValue {
    case let object as JSONObject:
      try object.forEach { key, value in
        let nextPrefix = prefix?.appending("[\(key)]") ?? key
        items.append(contentsOf: try makeQuery(from: value, prefix: nextPrefix))
      }
      
    case let array as JSONArray:
      guard let somePrefix = prefix else {
        throw APIError.notJSONObject
      }
      try array.forEach { element in
        items.append(contentsOf: try makeQuery(from: element, prefix: somePrefix + "[]"))
      }
      
    default:
      guard let somePrefix = prefix else {
        throw APIError.notJSONObject
      }
      items.append(URLQueryItem(name: somePrefix, value: String(describing: jsonValue)))
    }
    
    return items
  }
}

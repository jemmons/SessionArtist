import Foundation
import Medea



public struct Host {
  fileprivate let host: URL

  
  /// URL representing the host of the API.
  public var url: URL {
    // This just a public alias of `host` above. From the caller, `host.host` is ambiguous and redundant. But internally, `url` is overloaded and vague. So we use `host` internally and `url` externally.
    return host
  }
  
  
  public init(url: URL) {
    host = url
  }
  
  
  public init(urlString: String) throws {
    guard let url = URL(string: urlString) else {
      throw InitializationError.invalidURL
    }
    self.init(url: url)
  }
}



public enum Params {
  case data(Data), form([URLQueryItem]), json(JSONObject)
  
  init(_ data: Data) {
    self = .data(data)
  }
  
  
  init(_ form: [URLQueryItem]) {
    self = .form(form)
  }
  
  
  init(_ json: JSONObject) {
    self = .json(json)
  }
  
  
  func makeData() throws -> Data {
    switch self {
    case .data(let d):
      return d
    case .form(let f):
      //If lossy is true, this cannot return `nil`.
      return Helper.makeQuery(from: f).data(using: .utf8, allowLossyConversion: true)!
    case .json(let j):
      return try JSONHelper.data(from: j)
    }
  }
  
  
  func setContent(in oldHeaders: [HTTPHeaderField: String]) -> [HTTPHeaderField: String] {
    // If an explicit content type has been passed in, we don't want to overwrite it.
    guard oldHeaders[.contentType] == nil else {
      return oldHeaders
    }
    guard let newContentType = contentType else {
      return oldHeaders
    }
    var newHeaders = oldHeaders
    newHeaders[.contentType] = newContentType
    return newHeaders
  }
  
  
  private var contentType: String? {
    switch self {
    case .data:
      return nil
    case .form:
      return "application/x-www-form-urlencoded"
    case .json:
      return "application/json"
    }
  }
}


private extension Host {
  func getRequest(_ path: String?, params: [URLQueryItem]? = nil, headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path, params: params)
    return Helper.makeRequest(url, headers: headers)
  }
  
  
  func postRequest(_ path: String?, params: Params, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: params.setContent(in: headers))
    req.httpMethod = "POST"
    req.httpBody = try params.makeData()
    return req
  }
  
  
  func putRequest(_ path: String?, params: Params, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: params.setContent(in: headers))
    req.httpMethod = "PUT"
    req.httpBody = try params.makeData()
    return req
  }
  
  
  func deleteRequest(_ path: String?, headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: headers)
    req.httpMethod = "DELETE"
    return req
  }
  

//  func graphRequest(_ path: String?, query: String, variables: JSONObject? = nil, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
//    let json = try Helper.makeGraphJSON(query: SafeQuery(query), variables: variables)
//    return try postRequest(path, json: json, headers: headers)
//  }
//  
//  
//  func graphRequest(_ path: String?, queryNamed name: String, bundle: Bundle = Bundle.main,  variables: JSONObject? = nil, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
//    guard
//      let url = bundle.url(forResource: name, withExtension: "graphql"),
//      FileManager.default.fileExists(atPath: url.path) else {
//        throw FileError.fileNotFound
//    }
//    let query = try String(contentsOf: url)
//    return try graphRequest(path, query: query, variables: variables, headers: headers)
//  }
}



private struct SafeQuery {
  public let value: String
  public init(_ unsafe: String) {
    value = SafeQuery.escape(unsafe)
  }
  private static func escape(_ string: String) -> String {
    return string
      .replacingOccurrences(of: "\n", with: " ")
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
  }
}



private enum Helper {
  private enum ComponentError: Error {
    case malformed, badPath
  }
  
  
  static func makeGraphJSON(query: SafeQuery, variables: JSONObject?) throws -> JSONObject {
    var json: JSONObject = ["query": query.value]
    if let someVariables = variables {
      try JSONHelper.validate(someVariables)
      json["variables"] = someVariables
    }
    return json
  }
  
  
  static func makeQuery(from params: [URLQueryItem]) -> String {
    var comp = URLComponents()
    comp.queryItems = params
    //Can't be nil if we set `queryItems`. At worst, an empty string.
    return comp.query!
  }
  
  
  static func makeRequest(_ url: URL, headers: [HTTPHeaderField: String]) -> URLRequest {
    var req = URLRequest(url: url)
    headers.forEach { field, value in
      req.setValue(value, forHTTPHeaderField: field.description)
    }
    return req
  }

  
  static func makeURL(host: URL, path: String?, params: [URLQueryItem]? = nil) throws -> URL {
    var url = host
    if let somePath = path {
      url.appendPathComponent(somePath)
    }
    
    guard var comp = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      throw ComponentError.malformed
    }
    
    if let queryItems = params {
      comp.queryItems = (comp.queryItems ?? []) + queryItems
    }
    
    guard let newURL = comp.url else {
      throw ComponentError.badPath
    }
    return newURL
  }
}

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



public extension Host {
  func get(_ path: String?, params: [URLQueryItem]? = nil, headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path, params: params)
    return Helper.makeRequest(url, headers: headers)
  }
  
  
  func post(_ path: String?, data: Data?, headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: headers)
    req.httpMethod = "POST"
    req.httpBody = data
    return req
  }
  
  
  func post(_ path: String?, params: [URLQueryItem], headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let data = Helper.makeQuery(from: params)?.data(using: .utf8)
    let newHeaders = Helper.safeAddContentType("application/x-www-form-urlencoded", to: headers)
    return post(path, data: data, headers: newHeaders)
  }
  
  
  func post(_ path: String?, json: JSONObject, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
    let data = try JSONHelper.data(from: json)
    let newHeaders = Helper.safeAddContentType("application/json", to: headers)
    return post(path, data: data, headers: newHeaders)
  }
  
  
  func put(_ path: String?, data: Data?, headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: headers)
    req.httpMethod = "PUT"
    req.httpBody = data
    return req
  }
  
  
  func put(_ path: String?, params: [URLQueryItem], headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let data = Helper.makeQuery(from: params)?.data(using: .utf8)
    let newHeaders = Helper.safeAddContentType("application/x-www-form-urlencoded", to: headers)
    return put(path, data: data, headers: newHeaders)
  }
  
  
  func put(_ path: String?, json: JSONObject, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
    let data = try JSONHelper.data(from: json)
    let newHeaders = Helper.safeAddContentType("application/json", to: headers)
    return put(path, data: data, headers: newHeaders)
  }
  
  
  func delete(_ path: String?, headers: [HTTPHeaderField: String] = [:]) -> URLRequest {
    let url = try! Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: headers)
    req.httpMethod = "DELETE"
    return req
  }
  

  func graph(_ path: String?, query: String, variables: JSONObject? = nil, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
    let json = try Helper.makeGraphJSON(query: SafeQuery(query), variables: variables)
    return try post(path, json: json, headers: headers)
  }
  
  
  func graph(_ path: String?, queryNamed name: String, bundle: Bundle = Bundle.main,  variables: JSONObject? = nil, headers: [HTTPHeaderField: String] = [:]) throws -> URLRequest {
    guard
      let url = bundle.url(forResource: name, withExtension: "graphql"),
      FileManager.default.fileExists(atPath: url.path) else {
        throw FileError.fileNotFound
    }
    let query = try String(contentsOf: url)
    return try graph(path, query: query, variables: variables, headers: headers)
  }
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
  
  
  static func makeQuery(from params: [URLQueryItem]) -> String? {
    var comp = URLComponents()
    comp.queryItems = params
    return comp.query
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

  
  static func safeAddContentType(_ contentType: String, to oldHeaders: [HTTPHeaderField: String]) -> [HTTPHeaderField: String] {
    // If an explicit content type has been passed in, we don't want to overwrite it.
    guard oldHeaders[.contentType] == nil else {
      return oldHeaders
    }
    var newHeaders = oldHeaders
    newHeaders[.contentType] = contentType
    return newHeaders
  }
}

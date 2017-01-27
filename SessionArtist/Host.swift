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
}



public extension Host {
  func get(_ path: String, params: [URLQueryItem]? = nil, headers: [String: String] = [:]) -> URLRequest {
    let url = Helper.makeURL(host: host, path: path, params: params)
    return Helper.makeRequest(url, headers: headers)
  }
  
  
  func post(_ path: String, data: Data?, headers: [String: String] = [:]) -> URLRequest {
    let url = Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: headers)
    req.httpMethod = "POST"
    req.httpBody = data
    return req
  }
  
  
  func post(_ path: String, params: [URLQueryItem], headers: [String: String] = [:]) -> URLRequest {
    let data = Helper.makeQuery(from: params)?.data(using: .utf8)
    let newHeaders = Helper.safeAddContentType("application/x-www-form-urlencoded", to: headers)
    return post(path, data: data, headers: newHeaders)
  }
  
  
  func post(_ path: String, json: JSONObject, headers: [String: String] = [:]) throws -> URLRequest {
    let data = try JSONHelper.data(from: json)
    let newHeaders = Helper.safeAddContentType("application/json", to: headers)
    return post(path, data: data, headers: newHeaders)
  }
  
  
  func put(_ path: String, data: Data?, headers: [String: String] = [:]) -> URLRequest {
    let url = Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: headers)
    req.httpMethod = "PUT"
    req.httpBody = data
    return req
  }
  
  
  func put(_ path: String, params: [URLQueryItem], headers: [String: String] = [:]) -> URLRequest {
    let data = Helper.makeQuery(from: params)?.data(using: .utf8)
    let newHeaders = Helper.safeAddContentType("application/x-www-form-urlencoded", to: headers)
    return put(path, data: data, headers: newHeaders)
  }
  
  
  func put(_ path: String, json: JSONObject, headers: [String: String] = [:]) throws -> URLRequest {
    let data = try JSONHelper.data(from: json)
    let newHeaders = Helper.safeAddContentType("application/json", to: headers)
    return put(path, data: data, headers: newHeaders)
  }
  
  
  func delete(_ path: String, headers: [String: String] = [:]) -> URLRequest {
    let url = Helper.makeURL(host: host, path: path)
    var req = Helper.makeRequest(url, headers: headers)
    req.httpMethod = "DELETE"
    return req
  }
  

  func graph(_ path: String, query: String, variables: JSONObject? = nil, headers: [String: String] = [:]) throws -> URLRequest {
    let json = try Helper.makeGraphJSON(query: SafeQuery(query), variables: variables)
    return try post(path, json: json, headers: headers)
  }
  
  
  func graph(_ path: String, queryNamed name: String, bundle: Bundle = Bundle.main,  variables: JSONObject? = nil, headers: [String: String] = [:]) throws -> URLRequest {
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
  
  
  static func makeRequest(_ url: URL, headers: [String: String]) -> URLRequest {
    var req = URLRequest(url: url)
    headers.forEach { field, value in
      req.setValue(value, forHTTPHeaderField: field)
    }
    return req
  }

  
  static func makeURL(host: URL, path: String, params: [URLQueryItem]? = nil) -> URL {
    var comp = URLComponents(url: host, resolvingAgainstBaseURL: false)!
    comp.path = path
    if let queryItems = params {
      comp.queryItems = queryItems
    }
    return comp.url!
  }

  
  static func safeAddContentType(_ contentType: String, to oldHeaders: [String: String]) -> [String: String] {
    // If an explicit content type has been passed in, we don't want to overwrite it.
    guard oldHeaders["Content-Type"] == nil else {
      return oldHeaders
    }
    var newHeaders = oldHeaders
    newHeaders["Content-Type"] = contentType
    return newHeaders
  }
}

import Foundation
import Medea

public protocol Endpoint {
  static var scheme: String {get}
  static var host: String {get}
  static var port: Int {get}
  var request: URLRequest {get}
}



public extension Endpoint {
  static var scheme: String {
    return "https"
  }
  
  
  // We'd normally want to make this an `Int?` and use `nil` for the empty case. But that would mean implementations would have to be explicit with type in order to conform (i.e. `static var port: Int? = 100`). `Int` lets implementors infer type (`static var port = 100`), and negative numbers are a safe sentinel for ports.
  static var port: Int { return -1 }
  
  
  func get(_ path: String, params: [URLQueryItem]? = nil, headers: [String: String] = [:]) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path, params: params)
    return makeRequest(url, headers: headers)
  }
  
  
  func post(_ path: String, params: [URLQueryItem], headers: [String: String] = [:]) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = makeRequest(url, headers: headers)
    req.httpMethod = "POST"
    // If an explicit content type has been passed in, we don't want to overwrite it.
    if headers["Content-Type"] == nil {
      req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    req.httpBody = makeQuery(from: params)?.data(using: .utf8)
    return req
  }

  
  func post(_ path: String, json: JSONObject, headers: [String: String] = [:]) throws -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = makeRequest(url, headers: headers)
    req.httpMethod = "POST"
    // If an explicit content type has been passed in, we don't want to overwrite it.
    if headers["Content-Type"] == nil {
      req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    req.httpBody = try JSONHelper.data(from: json)
    return req
  }

  
  func put(_ path: String, params: [URLQueryItem], headers: [String: String] = [:]) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = makeRequest(url, headers: headers)
    req.httpMethod = "PUT"
    // If an explicit content type has been passed in, we don't want to overwrite it.
    if headers["Content-Type"] == nil {
      req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    req.httpBody = makeQuery(from: params)?.data(using: .utf8)
    return req
  }
  
  
  func put(_ path: String, json: JSONObject, headers: [String: String] = [:]) throws -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = makeRequest(url, headers: headers)
    req.httpMethod = "PUT"
    // If an explicit content type has been passed in, we don't want to overwrite it.
    if headers["Content-Type"] == nil {
      req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    req.httpBody = try JSONHelper.data(from: json)
    return req
  }
  
  
  func delete(_ path: String, headers: [String: String] = [:]) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = makeRequest(url, headers: headers)
    req.httpMethod = "DELETE"
    return req
  }
  
  
  private func makeQuery(from params: [URLQueryItem]) -> String? {
    var comp = URLComponents()
    comp.queryItems = params
    return comp.query
  }
  
  
  private func makeRequest(_ url: URL, headers: [String: String]) -> URLRequest {
    var req = URLRequest(url: url)
    headers.forEach { field, value in
      req.setValue(value, forHTTPHeaderField: field)
    }
    return req
  }
  
  
  private func makeURL(scheme: String, host: String, port: Int, path: String, params: [URLQueryItem]? = nil) -> URL {
    var comp = URLComponents()
    comp.scheme = scheme
    comp.host = host
    comp.path = path
    if port >= 0 {
      comp.port = port
    }
    if let queryItems = params {
      comp.queryItems = queryItems
    }
    return comp.url!
  }
}

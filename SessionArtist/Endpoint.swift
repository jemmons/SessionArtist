import Foundation

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
  
  
  func get(_ path: String, params: [URLQueryItem]? = nil) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path, params: params)
    return URLRequest(url: url)
  }
  
  
  func post(_ path: String, params: [URLQueryItem]) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.httpBody = makeQuery(from: params)?.data(using: .utf8)
    return req
  }
  
  
  func put(_ path: String, params: [URLQueryItem]) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = URLRequest(url: url)
    req.httpMethod = "PUT"
    //omitted from PUT for some reason.
    req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    req.httpBody = makeQuery(from: params)?.data(using: .utf8)
    return req
  }
  
  
  func delete(_ path: String) -> URLRequest {
    let url = makeURL(scheme: Self.scheme, host: Self.host, port: Self.port, path: path)
    var req = URLRequest(url: url)
    req.httpMethod = "DELETE"
    return req
  }
  
  
  private func makeQuery(from params: [URLQueryItem]) -> String? {
    var comp = URLComponents()
    comp.queryItems = params
    return comp.query
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

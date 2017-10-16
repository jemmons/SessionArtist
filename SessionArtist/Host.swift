import Foundation
import Medea



public struct Host {
  private let baseURL: URL
  private let session: URLSession
  
  
  public init(baseURL: URL, defaultHeaders: [HTTPHeaderField: String] = [:], timeout: TimeInterval = 15) {
    self.baseURL = baseURL
    session = Helper.makeSession(headers: defaultHeaders, timeout: timeout)
  }
}


public extension Host {
  //MARK: - ENDPOINT REQUEST
  func request(_ endpoint: EndpointConvertible) -> Request {
    return Request(session: session, request: endpoint.endpoint.request(from: baseURL))
  }
  
  
  //MARK: - CONVENIENCE REQUESTS
  func get(_ path: String, query: [URLQueryItem] = [], headers: [HTTPHeaderField: String] = [:]) -> Request {
    let params = query.isEmpty ? nil : Params(query)
    let endpoint = Endpoint(method: .get, path: path, params: params, headers: headers)
    return request(endpoint)
  }
  
  
  func post(_ path: String, params: Params, headers: [HTTPHeaderField: String] = [:]) -> Request {
    let endpoint = Endpoint(method: .post, path: path, params: params, headers: headers)
    return request(endpoint)
  }
  
  
  func post(_ path: String, json: ValidJSONObject, headers: [HTTPHeaderField: String] = [:]) -> Request {
    return post(path, params: .json(json), headers: headers)
  }


  func put(_ path: String, params: Params, headers: [HTTPHeaderField: String] = [:]) -> Request {
    let endpoint = Endpoint(method: .put, path: path, params: params, headers: headers)
    return request(endpoint)
  }
  
  
  func put(_ path: String, json: ValidJSONObject, headers: [HTTPHeaderField: String] = [:]) -> Request {
    return put(path, params: .json(json), headers: headers)
  }
  
  
  func delete(_ path: String, headers: [HTTPHeaderField: String] = [:]) -> Request {
    let endpoint = Endpoint(method: .delete, path: path, params: nil, headers: headers)
    return request(endpoint)
  }
}



private enum Helper {
  static func makeSession(headers: [HTTPHeaderField: String], timeout: TimeInterval) -> URLSession {
    let  config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.timeoutIntervalForRequest = timeout
    
    var sessionHeaders: [String: String] = [:]
    headers.forEach { sessionHeaders[$0.description] = $1 }
    config.httpAdditionalHeaders = sessionHeaders
    
    return URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
  }
}


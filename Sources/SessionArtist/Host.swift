import Foundation



public class Host {
  private let baseURL: URL
  private let session: URLSession
  
  
  public init(baseURL: URL, defaultHeaders: [HTTPHeaderField: String] = [:], timeout: TimeInterval = 15) {
    self.baseURL = baseURL
    session = Helper.makeSession(headers: defaultHeaders, timeout: timeout)
  }
}



public extension Host {
  var url: URL {
    return baseURL
  }
  
  
  var headers: [HTTPHeaderField: String] {
    var newHeaders: [HTTPHeaderField: String] = [:]
    session.configuration.httpAdditionalHeaders?.forEach { key, value in
      if
        let someKey = key as? String,
        let someValue = value as? String {
        newHeaders[HTTPHeaderField(string: someKey)] = someValue
      }
    }
    return newHeaders
  }
  
  
  var timeout: TimeInterval {
    return session.configuration.timeoutIntervalForRequest
  }
  
  
  // MARK: - ENDPOINT REQUEST
  func request(_ endpoint: EndpointConvertible) -> Request {
    return Request(session: session, request: endpoint.endpoint.request(from: baseURL))
  }
  
  
  // MARK: - CONVENIENCE REQUESTS
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
  
  
  /**
   A GraphQL query that sends response `Data` to a completion handler.
   
   This works a little differently from other verbs. Rather than taking a method, path, and headers, it relies on the default URL and headers of the host. This is because GraphQL requests are always POSTs, and always address the same endpoint. Easier to set it once (in host init), then forget it.
   
   And because GraphQL responses can only have one format (JSON), this provides a callback with `Data` ready for decoding rather than returning a `Request`.
   */
  func query(_ query: String, completion: @escaping (Result<(HTTPStatusCode, Data), Swift.Error>) -> Void) {
    post("", params: Params([URLQueryItem(name: "query", value: query)]))
      .data { res in
        completion(res.flatMap { code, _, data in return .success((code, data)) })
    }
  }

  
  /**
   A GraphQL query that decodes response and sends it to a completion handler.
   
   This works a little differently from other verbs. Rather than taking a method, path, and headers, it relies on the default URL and headers of the host. This is because GraphQL requests are always POSTs, and always address the same endpoint. Easier to set it once (in host init), then forget it.
   
   And because GraphQL responses can only have one format (JSON), this provides a callback with a decoded model rather than returning a `Request`.
   */
  func query<Model>(_ query: String, model: Model.Type, completion: @escaping (Result<Model, Swift.Error>) -> Void) where Model: Decodable {
    self.query(query) { res in
      completion(res.flatMap { code, data in
        switch code {
        case .ok:
          do {
            return .success(try JSONDecoder().decode(Model.self, from: data))
          } catch {
            return .failure(error)
          }
        case let code:
          return .failure(Error.notOK(code))
        }
      })
    }
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

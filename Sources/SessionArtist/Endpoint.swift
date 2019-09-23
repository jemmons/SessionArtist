import Foundation



public protocol EndpointConvertible {
  var endpoint: Endpoint { get }
}



public struct Endpoint {
  public let method: HTTPMethod
  public let path: String
  public let params: Params?
  private let _headers: [HTTPHeaderField: String]
  public var headers: [HTTPHeaderField: String] {
    switch method {
    case .put, .patch, .post:
      return _headers.merging(params?.contentType ?? [:]) { existing, _ in
        // If `oldHeaders` has an explicit content type, don't overwrite it.
        return existing
      }
    default:
      return _headers
    }
  }
  
  
  public init(method: HTTPMethod, path: String, params: Params? = nil, headers: [HTTPHeaderField: String] = [:]) {
    self.method = method
    self.path = path
    self.params = params
    _headers = headers
  }
  
  
  public func request(from baseURL: URL) -> URLRequest {
    var req = URLRequest(url: url(from: baseURL))
    req.httpMethod = method.description
    headers.forEach { key, value in
      req.addValue(value, forHTTPHeaderField: key.description)
    }
    req.httpBody = body
    return req
  }
}



private extension Endpoint {
  var queryItems: [URLQueryItem]? {
    switch method {
    case .get:
      return params?.makeQuery()
    default:
      return nil
    }
  }
  
  
  var body: Data? {
    switch method {
    case .patch, .post, .put:
      return params?.makeData()
    default:
      return nil
    }
  }
  
  
  func url(from baseURL: URL) -> URL {
    guard var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
      fatalError("Problem resolving against base URL")
    }
    
    comps.appendPathComponent(path)
    
    if [.get, .postQuery].contains(method) {
      comps.queryItems = params?.makeQuery()
    }
    
    guard let url = comps.url else {
      fatalError("Problem with leading “/” in path.")
    }
    
    return url
  }
}



extension Endpoint: EndpointConvertible {
  public var endpoint: Endpoint {
    return self
  }
}



private extension URLComponents {
  private enum K {
    static let delimiter = "/"
    static let pad = "|"
    static let delimiterSet = CharacterSet(charactersIn: delimiter)
  }
  
  
  mutating func appendPathComponent(_ component: String) {
    path = trimmingBack(path) + K.delimiter + trimmingFront(component)
  }
  
  
  private func trimmingFront(_ string: String) -> String {
    let trimmed = (string + K.pad).trimmingCharacters(in: K.delimiterSet)
    return String(trimmed.dropLast())
  }
  
  
  private func trimmingBack(_ string: String) -> String {
    let trimmed = (K.pad + string).trimmingCharacters(in: K.delimiterSet)
    return String(trimmed.dropFirst())
  }
}

import Foundation
import typealias Medea.JSONObject


private enum Const {
  static let timeout: TimeInterval = 15.0
}



public class APISession<T: Endpoint>{
  private let session: URLSession
  private let host: Host
  
  
  convenience public init(host: String, headers: [HTTPHeaderField: String] = [:], timeout: TimeInterval = Const.timeout) throws {
    let newHost = try Host(urlString: host)
    self.init(host: newHost, headers: headers, timeout: timeout)
  }
  
  
  convenience public init(host: URL, headers: [HTTPHeaderField: String] = [:], timeout: TimeInterval = Const.timeout) {
    self.init(host: Host(url: host), headers: headers, timeout: timeout)
  }
  
  
  public init(host: Host, headers: [HTTPHeaderField: String] = [:], timeout: TimeInterval = Const.timeout) {
    self.host = host
    session = Helper.makeSession(headers: headers, timeout: timeout)
  }
  
  
  private func withTask(for endpoint: T, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
    let task = session.dataTask(with: endpoint.makeRequest(host: host)) { data, res, error in
      completion(data, res, error)
    }
    task.resume()
    return task
  }
  
  
  @discardableResult public func dataTask(for endpoint: T, completion: @escaping (Result<DataResponse>)->Void = {_ in}) -> URLSessionTask {
    return withTask(for: endpoint) { data, res, error in
      completion(ResultFactory.makeDataResponseResult(data: data, response: res, error: error))
    }
  }


  @discardableResult public func jsonObjectTask(for endpoint: T, completion: @escaping (Result<JSONObjectResponse>)->Void = {_ in}) -> URLSessionTask {
    return withTask(for: endpoint) { data, res, error in
      completion(ResultFactory.makeJSONObjectResponseResult(data: data, response: res, error: error))
    }
  }


  @discardableResult public func jsonArrayTask(for endpoint: T, completion: @escaping (Result<JSONArrayResponse>)->Void = {_ in}) -> URLSessionTask {
    return withTask(for: endpoint) { data, res, error in
      completion(ResultFactory.makeJSONArrayResponseResult(data: data, response: res, error: error))
    }
  }
  
  
  @discardableResult public func graphTask(for endpoint: T, objectName: String, completion: @escaping (Result<JSONObjectResponse>)->Void = {_ in}) -> URLSessionTask {
    return withTask(for: endpoint) { data, res, error in
      let result = ResultFactory.makeJSONObjectResponseResult(data: data, response: res, error: error)
      switch result {
      case .success(200, let json):
        completion(Helper.parseGraphJSON(json, objectName: objectName))
      default: //it's an .error or a non-200 response
        completion(result)
      }
    }
  }
}



private enum Helper {
  static func makeSession(headers: [HTTPHeaderField: String], timeout: TimeInterval) -> URLSession {
    let  config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.httpAdditionalHeaders = sessionHeaders(from: headers)
    config.timeoutIntervalForRequest = timeout
    
    return URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
  }
  
  
  private static func sessionHeaders(from headers: [HTTPHeaderField: String]) -> [String: String] {
    var sessionHeaders = [String: String]()
    headers.forEach { sessionHeaders[$0.description] = $1 }
    return sessionHeaders
  }
  
  
  static func parseGraphJSON(_ json: JSONObject, objectName: String) -> Result<JSONObjectResponse> {
    let object = (json["data"] as? JSONObject)?[objectName] as? JSONObject
    let errorMessage = (json["errors"] as? [JSONObject])?.first?["message"] as? String
    let hasObject = (json["data"] as? JSONObject)?.keys.contains(objectName) ?? false

    switch (hasObject, object, errorMessage) {
    case (true, _, let message?):
      return .failure(GraphQLError.execution(message: message))
    
    case (false, _, let message?):
      return .failure(GraphQLError.syntaxOrValidation(message: message))
    
    case (true, let obj?, nil):
      return .success(status: 200, jsonObject: obj)
    
    default:
      return .failure(GraphQLError.unknown)
    }
  }
}




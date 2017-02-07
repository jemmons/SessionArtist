import Foundation
import typealias Medea.JSONObject


private enum Const {
  static let timeout: TimeInterval = 15.0
}



public class APISession<T: Endpoint>{
  private let session: URLSession
  private let host: Host
  
  
  convenience public init?(host: String, headers: [String: String] = [:], timeout: TimeInterval = Const.timeout) {
    guard let newHost = Host(urlString: host) else {
      return nil
    }
    self.init(host: newHost, headers: headers, timeout: timeout)
  }
  
  
  convenience public init(host: URL, headers: [String: String] = [:], timeout: TimeInterval = Const.timeout) {
    self.init(host: Host(url: host), headers: headers, timeout: timeout)
  }
  
  
  public init(host: Host, headers: [String: String] = [:], timeout: TimeInterval = Const.timeout) {
    self.host = host
    session = Helper.makeSession(headers: headers, timeout: timeout)
  }
  
  
  private func task<R: ResponseResult>(for endpoint: T, completion: @escaping (R) -> Void) -> URLSessionTask {
    let task = session.dataTask(with: endpoint.makeRequest(host: host)) { data, res, error in
      completion(R(data: data, response: res, error: error))
    }
    task.resume()
    return task
  }
  
  
  @discardableResult public func dataTask(for endpoint: T, completion: @escaping (DataResponse)->Void = {_ in}) -> URLSessionTask {
    return task(for: endpoint, completion: completion)
  }


  @discardableResult public func jsonObjectTask(for endpoint: T, completion: @escaping (JSONObjectResponse)->Void = {_ in}) -> URLSessionTask {
    return task(for: endpoint, completion: completion)
  }


  @discardableResult public func jsonArrayTask(for endpoint: T, completion: @escaping (JSONArrayResponse)->Void = {_ in}) -> URLSessionTask {
    return task(for: endpoint, completion: completion)
  }
  
  
  @discardableResult public func graphTask(for endpoint: T, objectName: String, completion: @escaping (JSONObjectResponse)->Void = {_ in}) -> URLSessionTask {
    return task(for: endpoint) { (res: JSONObjectResponse) in
      switch res {
      case .response(200, let json):
        completion(Helper.parseGraphJSON(json, objectName: objectName))
      default: //it's an .error or a non-200 response
        completion(res)
      }
    }
  }
}



private enum Helper {
  static func makeSession(headers: [String: String], timeout: TimeInterval) -> URLSession {
    let  config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.httpAdditionalHeaders = headers
    config.timeoutIntervalForRequest = timeout
    
    return URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
  }
  
  
  static func parseGraphJSON(_ json: JSONObject, objectName: String) -> JSONObjectResponse {
    let object = (json["data"] as? JSONObject)?[objectName] as? JSONObject
    let errorMessage = (json["errors"] as? [JSONObject])?.first?["message"] as? String
    let hasObject = (json["data"] as? JSONObject)?.keys.contains(objectName) ?? false

    switch (hasObject, object, errorMessage) {
    case (true, _, let message?):
      return .failure(GraphQLError.execution(message: message))
    
    case (false, _, let message?):
      return .failure(GraphQLError.syntaxOrValidation(message: message))
    
    case (true, let obj?, nil):
      return .response(status: 200, jsonObject: obj)
    
    default:
      return .failure(GraphQLError.unknown)
    }
  }
}




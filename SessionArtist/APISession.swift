import Foundation
import Medea



public typealias JSONObject = Medea.JSONObject
public typealias JSONArray = Medea.JSONArray



private enum Const {
  static let timeout: TimeInterval = 15.0
}


public enum ResponseError: Error {
  case invalidResponse, unknown
}



private protocol ResponseResult {
  init(data: Data?, response: URLResponse?, error: Error?)
}



public enum JSONObjectResponse: ResponseResult {
  case response(status: Int, jsonObject: JSONObject)
  case failure(Error)


  public init(data: Data?, response: URLResponse?, error: Error?) {
    switch ResponseParser(data: data, response: response, error: error) {
    case let .error(e):
      self = .failure(e)
    case let .empty(s):
      self = .response(status: s, jsonObject: [:])
    case let .data(d, s):
      do{
        self = .response(status: s, jsonObject: try JSONHelper.jsonObject(from: d))
      } catch let e {
        self = .failure(e)
      }
    }
  }
}



public enum JSONArrayResponse: ResponseResult {
  case response(status: Int, jsonArray: JSONArray)
  case failure(Error)
  
  
  public init(data: Data?, response: URLResponse?, error: Error?) {
    switch ResponseParser(data: data, response: response, error: error) {
    case let .error(e):
      self = .failure(e)
    case let .empty(s):
      self = .response(status: s, jsonArray: [])
    case let .data(d, s):
      do{
        self = .response(status: s, jsonArray: try JSONHelper.jsonArray(from: d))
      } catch let e {
        self = .failure(e)
      }
    }
  }
}



public enum DataResponse: ResponseResult {
  case response(status: Int, data: Data)
  case failure(Error)


  public init(data: Data?, response: URLResponse?, error: Error?) {
    switch ResponseParser(data: data, response: response, error: error) {
    case let .error(e):
      self = .failure(e)
    case let .empty(s):
      self = .response(status: s, data: Data())
    case let .data(d, s):
      self = .response(status: s, data: d)
    }
  }
}



public struct APISession<T: Endpoint>{
  private let session: URLSession
  private let host: Host
  
  
  public init(host: String, headers: [String: String] = [:], timeout: TimeInterval = Const.timeout) {
    let hostURL = URL(string: host)!
    self.init(host: hostURL, headers: headers, timeout: timeout)
  }
  
  
  public init(host: URL, headers: [String: String] = [:], timeout: TimeInterval = Const.timeout){
    self.host = Host(url: host)
    session = SessionHelper.makeSession(headers: headers, timeout: timeout)
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
}



private enum SessionHelper {
  static func makeSession(headers: [String: String], timeout: TimeInterval) -> URLSession {
    let  config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.httpAdditionalHeaders = headers
    config.timeoutIntervalForRequest = timeout
    
    return URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
  }
}



private enum ResponseParser {
  case error(Error), empty(status: Int), data(Data, status: Int)
  
  init(data: Data?, response: URLResponse?, error: Error?) {
    switch (data, response, error) {
    case let (_, _, e?):
      self = .error(e)
      return
    case let (d?, r?, _):
      guard let status = (r as? HTTPURLResponse)?.statusCode else {
        self = .error(ResponseError.invalidResponse)
        return
      }
      guard d.count > 0 else {
        self = .empty(status: status)
        return
      }
      self = .data(d, status: status)
    default:
      self = .error(ResponseError.unknown)
    }
  }
}


import Foundation
import Medea



public typealias JSONObject = Medea.JSONObject



public enum ResponseError: Error {
  case invalidResponse, invalidJSONObject, unknown
}



private protocol ResponseResult {
  init(data: Data?, response: URLResponse?, error: Error?)
}



public enum JSONResponse: ResponseResult {
  case response(status: Int, json: JSONObject)
  case failure(Error)


  public init(data: Data?, response: URLResponse?, error: Error?) {
    switch (data, response, error) {
    case let (_, _, e?):
      self = .failure(e)
      return
    case let (d?, r?, _):
      guard let status = (r as? HTTPURLResponse)?.statusCode else {
        self = .failure(ResponseError.invalidResponse)
        return
      }
      guard d.count > 0 else {
        self = .response(status: status, json: [:])
        return
      }
      guard let json = try? JSONHelper.json(from: d) else {
        self = .failure(ResponseError.invalidJSONObject)
        return
      }
      self = .response(status: status, json: json)
    default:
      self = .failure(ResponseError.unknown)
    }
  }
}



public enum DataResponse: ResponseResult {
  case response(status: Int, data: Data)
  case failure(Error)
  
  public init(data: Data?, response: URLResponse?, error: Error?) {
    switch (data, response, error) {
    case let (_, _, e?):
      self = .failure(e)
      return
    case let (d?, r?, _):
      guard let status = (r as? HTTPURLResponse)?.statusCode else {
        self = .failure(ResponseError.invalidResponse)
        return
      }
      self = .response(status: status, data: d)
    default:
      self = .failure(ResponseError.unknown)
    }
  }
}



public struct APISession<T: Endpoint>{
  private let session: URLSession
  
  
  public init(){
    session = SessionHelper.makeSession()
  }
  
  
  private func task<R: ResponseResult>(for endpoint: T, completion: @escaping (R) -> Void) -> URLSessionTask {
    let task = session.dataTask(with: endpoint.request) { data, res, error in
      completion(R(data: data, response: res, error: error))
    }
    task.resume()
    return task
  }
  
  
  @discardableResult public func dataTask(for endpoint: T, completion: @escaping (DataResponse)->Void) -> URLSessionTask {
    return task(for: endpoint, completion: completion)
  }


  @discardableResult public func jsonTask(for endpoint: T, completion: @escaping (JSONResponse)->Void) -> URLSessionTask {
    return task(for: endpoint, completion: completion)
  }
}



fileprivate enum SessionHelper {
  static func makeConfig() -> URLSessionConfiguration {
    return URLSessionConfiguration.default
  }
  static func makeSession() -> URLSession {
    return URLSession(configuration: makeConfig())
  }
}

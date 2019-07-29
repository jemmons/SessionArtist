import Foundation
import Medea



public class Request {
  public typealias DataCompletionHandler = (Result<(code: HTTPStatusCode, contentType: String?, body: Data)>) -> Void
  public typealias JSONCompletionHandler = (Result<(code: HTTPStatusCode, json: AnyJSON)>) -> Void
  public typealias JSONObjectCompletionHandler = (Result<(code: HTTPStatusCode, json: JSONObject)>) -> Void
  public typealias JSONArrayCompletionHandler = (Result<(code: HTTPStatusCode, json: JSONArray)>) -> Void
  public typealias TextCompletionHandler = (Result<(code: HTTPStatusCode, text: String)>) -> Void

  
  private let session: URLSession
  private let request: URLRequest
  public var urlRequest: URLRequest {
    // Note the request we actually want is the one that will be sent by the session. That is: `request` merged with the properties of `session` — particularly the `httpAdditionalHeaders` of the `session`'s config.
    guard var newRequest = session.dataTask(with: request).currentRequest else {
      fatalError("Couldn't retrieve request from task explicitly created with it.")
    }

    // There's a bug in iOS 13/Catalina that doesn't copy the session's `httpAdditionalHeaders` over to a request until the request's task has been `resume`'d. So we have to manually merge the headers, instead.
    if #available(iOS 13, macOS 10.15, *) {
      let reqHeaders = newRequest.allHTTPHeaderFields ?? [:]
      let sessionHeaders = (session.configuration.httpAdditionalHeaders as? [String: String]) ?? [:]
      newRequest.allHTTPHeaderFields = reqHeaders.merging(sessionHeaders) { reqHeader, _ in reqHeader }
    }

    return newRequest
  }

  
  internal init(session: URLSession, request: URLRequest) {
    self.session = session
    self.request = request
  }
}



public extension Request {
  @discardableResult
  func data(_ completion: @escaping DataCompletionHandler) -> URLSessionTask {
    return makeTask(completion: completion)
  }
    
    
  @discardableResult
  func json(_ completion: @escaping JSONCompletionHandler) -> URLSessionTask {
    return data(Helper.dataHandler(from: completion) {
      return try JSONHelper.anyJSON(from: $0)
    })
  }
  
  
  @discardableResult
  func jsonObject(_ completion: @escaping JSONObjectCompletionHandler) -> URLSessionTask {
    return data(Helper.dataHandler(from: completion) {
      return try JSONHelper.jsonObject(from: $0)
    })
  }


  @discardableResult
  func jsonArray(_ completion: @escaping JSONArrayCompletionHandler) -> URLSessionTask {
    return data(Helper.dataHandler(from: completion) {
      return try JSONHelper.jsonArray(from: $0)
    })
  }
}



private extension Request {
  func makeTask(completion: @escaping DataCompletionHandler) -> URLSessionTask {
    let task = session.dataTask(with: request) { data, res, error in
      switch (data, res, error) {
      case let (_, _, e?):
        completion(.failure(e))
        
      case let (d?, r?, _):
        guard let httpResponse = r as? HTTPURLResponse else {
          completion(.failure(HTTPError.notHTTP))
          return
        }
        guard let code = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
          completion(.failure(HTTPError.unknownCode(httpResponse.statusCode)))
          return
        }
        completion(.success((code: code, contentType: Helper.contentType(from: httpResponse.allHeaderFields), body: d)))
        
      default:
        // Either there was data and no response, response and no data, or no data, response, or error. All of which should be impossible.
        fatalError("URLSession API is broken.")
      }
    }
    task.resume()
    return task
  }
}



private enum Helper {
  static func contentType(from dict: [AnyHashable: Any]) -> String? {
    return dict.first { key, _ in
      guard let stringKey = key as? String else {
        return false
      }
      return stringKey.caseInsensitiveCompare(HTTPHeaderField.contentType.description) == .orderedSame
    }?.value as? String
  }


  static func dataHandler<T>(from handler: @escaping (Result<(code: HTTPStatusCode, json: T)>) -> Void, factory: @escaping (Data) throws -> T) -> Request.DataCompletionHandler {
    return { (res: Result<(code: HTTPStatusCode, contentType: String?, body: Data)>) -> Void in
      let jsonResult = res.flatMap { code, _, body -> Result<(code: HTTPStatusCode, json: T)> in
        return .success((code: code, json: try factory(body)))
      }
      handler(jsonResult)
    }
  }
}

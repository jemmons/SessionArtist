import Foundation



public class Request {
  public typealias DataCompletionHandler = (Result<(code: HTTPStatusCode, contentType: String?, body: Data), Error>) -> Void
  public typealias JSONObjectCompletionHandler = (Result<(code: HTTPStatusCode, json: JSONObject), Error>) -> Void
  public typealias JSONArrayCompletionHandler = (Result<(code: HTTPStatusCode, json: JSONArray), Error>) -> Void
  public typealias TextCompletionHandler = (Result<(code: HTTPStatusCode, text: String), Error>) -> Void

  
  private let session: URLSession
  private let request: URLRequest
  public var urlRequest: URLRequest {
    // Note the request we actually want is the one that will be sent by the session. That is: `request` merged with the properties of `session` — particularly the `httpAdditionalHeaders` of the `session`'s config.
    guard var newRequest = session.dataTask(with: request).currentRequest else {
      preconditionFailure("Couldn’t retrieve request from task explicitly created with it.")
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
   
  
  func data() async throws -> (code: HTTPStatusCode, contentType: String?, body: Data) {
    try await withCheckedThrowingContinuation { data($0.resume) }
  }
    
    
  @discardableResult
  func jsonObject(_ completion: @escaping JSONObjectCompletionHandler) -> URLSessionTask {
    return data(Helper.dataHandler(from: completion) {
      guard let jsonObject = try JSONSerialization.jsonObject(with: $0, options: []) as? JSONObject else {
        throw APIError.notJSONObject
      }
      return jsonObject
    })
  }
  
  
  func jsonObject() async throws -> (code: HTTPStatusCode, json: JSONObject) {
    try await withCheckedThrowingContinuation { jsonObject($0.resume) }
  }


  @discardableResult
  func jsonArray(_ completion: @escaping JSONArrayCompletionHandler) -> URLSessionTask {
    return data(Helper.dataHandler(from: completion) {
      guard let jsonArray = try JSONSerialization.jsonObject(with: $0, options: []) as? JSONArray else {
        throw APIError.notJSONArray
      }
      return jsonArray
    })
  }
  
  
  func jsonArray() async throws -> (code: HTTPStatusCode, json: JSONArray) {
    try await withCheckedThrowingContinuation { jsonArray($0.resume) }
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
          completion(.failure(APIError.notHTTP))
          return
        }
        guard let code = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
          completion(.failure(APIError.unknownStatusCode(httpResponse.statusCode)))
          return
        }
        completion(.success((code: code, contentType: Helper.contentType(from: httpResponse.allHeaderFields), body: d)))
        
      default:
        // Either there was data and no response, response and no data, or no data, response, or error. All of which should be impossible.
        preconditionFailure("URLSession API is broken.")
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


  static func dataHandler<T>(from handler: @escaping (Result<(code: HTTPStatusCode, json: T), Error>) -> Void, factory: @escaping (Data) throws -> T) -> Request.DataCompletionHandler {
    return { (res: Result<(code: HTTPStatusCode, contentType: String?, body: Data), Error>) -> Void in
      let jsonResult = res.flatMap { code, _, body -> Result<(code: HTTPStatusCode, json: T), Error> in
        do {
          return .success((code: code, json: try factory(body)))
        } catch {
          return .failure(error)
        }
      }
      handler(jsonResult)
    }
  }
}

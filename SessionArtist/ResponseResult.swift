import Foundation
import Medea



public enum ResponseError: Error {
  case invalidResponse, unknown
}



internal protocol ResponseResult {
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

import Foundation
import Medea



public enum ResponseError: Error {
  case invalidResponse, unknown
}



public typealias JSONObjectResponse = (status: Int, jsonObject: JSONObject)
public typealias JSONArrayResponse = (status: Int, jsonArray: JSONArray)
public typealias DataResponse = (status: Int, data: Data)



internal enum ResultFactory {
   static func makeJSONObjectResponseResult(data: Data?, response: URLResponse?, error: Error?) -> Result<JSONObjectResponse> {
    switch ResponseParser(data: data, response: response, error: error) {
    case let .error(e):
      return .failure(e)
    case let .empty(s):
      return .success(status: s, jsonObject: [:])
    case let .data(d, s):
      do{
        return .success(status: s, jsonObject: try JSONHelper.jsonObject(from: d))
      } catch let e {
        return .failure(e)
      }
    }
  }
  
  
  static func makeJSONArrayResponseResult(data: Data?, response: URLResponse?, error: Error?) -> Result<JSONArrayResponse> {
    switch ResponseParser(data: data, response: response, error: error) {
    case let .error(e):
      return .failure(e)
    case let .empty(s):
      return .success(status: s, jsonArray: [])
    case let .data(d, s):
      do{
        return .success(status: s, jsonArray: try JSONHelper.jsonArray(from: d))
      } catch let e {
        return .failure(e)
      }
    }
  }
  
  
  static func makeDataResponseResult(data: Data?, response: URLResponse?, error: Error?) -> Result<DataResponse> {
    switch ResponseParser(data: data, response: response, error: error) {
    case let .error(e):
      return .failure(e)
    case let .empty(s):
      return .success(status: s, data: Data())
    case let .data(d, s):
      return .success(status: s, data: d)
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

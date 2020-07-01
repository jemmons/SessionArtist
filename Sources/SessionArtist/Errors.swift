import Foundation



public enum Error: LocalizedError {
  case notHTTP, unknownStatusCode(Int), notJSONObject, notJSONArray, invalidJSONObject, notOK(HTTPStatusCode)
  
  
  public var errorDescription: String? {
    switch self {
    case .notHTTP:
      return "The response was not in the expected format."
    case .unknownStatusCode(let code):
      return "The code “\(code)” is not a valid HTTP status."
    case .notOK(let code):
      return "Expected “\(HTTPStatusCode.ok)” but got “\(code)”."
    case .notJSONObject:
      return "Expected an object, but got some other JSON type."
    case .notJSONArray:
      return "Expected an array, but got some other JSON type."
    case .invalidJSONObject:
      return "The given object is not valid JSON."

    }
  }
  
  
  public var failureReason: String? {
    switch self {
    case .notHTTP, .unknownStatusCode, .notOK:
      return "HTTP Error"
    case .notJSONObject, .notJSONArray, .invalidJSONObject:
      return "JSON Error"
    }
  }
}

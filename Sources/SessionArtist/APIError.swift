import Foundation



public enum APIError: LocalizedError {
  case notHTTP, unknownStatusCode(Int), notJSONObject, notJSONArray, invalidJSONObject, exceptionalStatusCode(HTTPStatusCode)
  
  
  public var errorDescription: String? {
    switch self {
    case .notHTTP:
      return "The response was not in the expected format."
    case .unknownStatusCode(let code):
      return "The code “\(String(code))” is not a valid HTTP status."
    case .notJSONObject:
      return "Expected an object, but got some other JSON type."
    case .notJSONArray:
      return "Expected an array, but got some other JSON type."
    case .invalidJSONObject:
      return "The given object is not valid JSON."
    case .exceptionalStatusCode(let code):
      return "Service responded with “\(code)”."
    }
  }
  
  
  public var failureReason: String? {
    switch self {
    case .notHTTP, .unknownStatusCode:
      return "HTTP Error"
    case .notJSONObject, .notJSONArray, .invalidJSONObject:
      return "JSON Error"
    case .exceptionalStatusCode:
      return "Service Error"
    }
  }
}

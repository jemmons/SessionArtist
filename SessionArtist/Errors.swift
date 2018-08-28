import Foundation



public enum HTTPError: LocalizedError {
  case notHTTP, unknownCode(Int)
  
  
  public var errorDescription: String? {
    switch self {
    case .notHTTP:
      return "The response was not in the expected format."
    case .unknownCode(let code):
      return "The code “\(String(code))” is not a valid HTTP status."
    }
  }
}

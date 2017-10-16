import Foundation

public enum HTTPError: Error {
  case notHTTP, unknownCode(Int)
}


import Foundation



public protocol Endpoint {
  func makeRequest(host: Host) -> URLRequest
}




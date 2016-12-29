import Foundation
import XCTest
import SessionArtist



private enum DefaultEndpoint: Endpoint {
  static let host = "example.com"
  
  case getEndpoint, postEndpoint, putEndpoint, deleteEndpoint
  
  var request: URLRequest {
    switch self {
    case .getEndpoint:
      return get("/")
    case .postEndpoint:
      return post("/", params: [])
    case .putEndpoint:
      return put("/", params: [])
    case .deleteEndpoint:
      return delete("/")
    }
  }
}



private enum InsecureEndpoint: Endpoint {
  static let host = "example.com"
  static let scheme = "http"
  
  case anEndpoint
  
  var request: URLRequest {
    return get("/")
  }
}



private enum PerfidyEndpoint: Endpoint {
  static let host = "localhost"
  static let scheme = "http"
  static let port = 10175
  
  case anEndpoint
  
  var request: URLRequest {
    return get("/")
  }
}



class EndpointTests: XCTestCase {
  func testDefaultEndpoint() {
    let get = DefaultEndpoint.getEndpoint.request
    XCTAssertEqual(get.url!.absoluteString, "https://example.com/")
    XCTAssertEqual(get.httpMethod, "GET")
    
    let post = DefaultEndpoint.postEndpoint.request
    XCTAssertEqual(post.httpMethod, "POST")

    let put = DefaultEndpoint.putEndpoint.request
    XCTAssertEqual(put.httpMethod, "PUT")

    let delete = DefaultEndpoint.deleteEndpoint.request
    XCTAssertEqual(delete.httpMethod, "DELETE")
  }


  func testInsecureEndpoint() {
    let subject = InsecureEndpoint.anEndpoint.request
    XCTAssertEqual(subject.url!.absoluteString, "http://example.com/")
  }


  func testPerfidyEndpoint() {
    let subject = PerfidyEndpoint.anEndpoint.request
    XCTAssertEqual(subject.url!.absoluteString, "http://localhost:10175/")
  }
}

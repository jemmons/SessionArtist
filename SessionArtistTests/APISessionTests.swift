import XCTest
import SessionArtist
import Perfidy




private enum PerfidyEndpoint: Endpoint {
  static let scheme = "http"
  static let host = "localhost"
  static let port = 10175

  case getEndpoint, postEndpoint, putEndpoint, deleteEndpoint
  
  var request: URLRequest {
    switch self {
    case .getEndpoint:
      return get("/get")
    case .postEndpoint:
      return post("/post", params: [])
    case .putEndpoint:
      return put("/put", params: [])
    case .deleteEndpoint:
      return delete("/delete")
    }
  }
}



private enum API {
  static let perfidy = APISession<PerfidyEndpoint>()
}



class APISessionTests: XCTestCase {
  func testGet() {
    let shouldRespond = expectation(description: "should respond")
    FakeServer.runWith(defaultStatusCode: 500) { server in
      server.add("GET /get", response: 201)
      API.perfidy.task(for: .getEndpoint) { _, res, _ in
        XCTAssertEqual((res as! HTTPURLResponse).statusCode, 201)
        shouldRespond.fulfill()
      }
      waitForExpectations(timeout: 2.0, handler: nil)
    }
  }
}

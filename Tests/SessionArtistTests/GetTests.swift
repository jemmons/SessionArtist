import Foundation
import XCTest
import SessionArtist
import Perfidy



class GetTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)

  
  func testGetWithoutParams() throws {
    try doFakeGet("/test", query: [], headers: [:]) { req in
      XCTAssertFalse(req.url!.absoluteString.contains("?"))
    }
  }

  
  func testGetParams() throws {
    try doFakeGet("/test", query: [URLQueryItem(name: "foo", value: "bar")], headers: [:]) { req in
      XCTAssertNil(req.allHTTPHeaderFields!["Content-Type"])
      XCTAssertEqual(req.url!.query, "foo=bar")
    }
  }
  
  
  func testGetHeaders() throws {
    try doFakeGet("/test", query: [], headers: [.accept: "foobar"]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Accept"], "foobar")
    }
  }
}



private extension GetTests {
  func doFakeGet(_ path: String, query: [URLQueryItem], headers: [HTTPHeaderField: String], getHandler: @escaping (URLRequest)->Void) throws {
    let expectedRequest = expectation(description: "waiting for request")
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add(Route(method: .get, path: path)) { req in
      getHandler(req)
      expectedRequest.fulfill()
    }
      
    fakeHost.get(path, query: query, headers: headers).data { res in
      if case .success((.ok, _, _)) = res {
        expectedResponse.fulfill()
      }
    }
    
    wait(for: [expectedRequest, expectedResponse], timeout: 1)
  }
}

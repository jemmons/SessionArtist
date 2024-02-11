import Foundation
import XCTest
import SessionArtist
import Perfidy



class PutTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)
  
  
  func testPutParams() throws {
    try doFakePut("/test", json: ["foo": "bar"], headers: [:]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Content-Type"], "application/json")
      XCTAssertEqual(req.httpBody, "{\"foo\":\"bar\"}".data(using: .utf8))
    }
  }
  
  
  func testPutEmptyParams() throws {
    try doFakePut("/test", json: [:], headers: [:]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Content-Type"], "application/json")
      XCTAssertEqual(req.httpBody, "{}".data(using: .utf8))
    }
  }
  
  
  func testPutHeaders() throws {
    try doFakePut("/test", json: [:], headers: [.accept: "foobar"]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Accept"], "foobar")
    }
  }
}



private extension PutTests {
  func doFakePut(_ path: String, json: JSONObject, headers: [HTTPHeaderField: String], putHandler: @escaping (URLRequest)->Void) throws {
    let expectedRequest = expectation(description: "waiting for request")
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add(Route(method: .put, path: path)) { req in
      putHandler(req)
      expectedRequest.fulfill()
    }
    
    let validJSON = try! ValidJSONObject(json)
    fakeHost.put(path, json: validJSON, headers: headers).data { res in
      if case .success((.ok, _, _)) = res {
        expectedResponse.fulfill()
      }
    }
    
    wait(for: [expectedRequest, expectedResponse], timeout: 1)
  }
}

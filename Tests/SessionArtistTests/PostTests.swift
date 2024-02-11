import Foundation
import XCTest
import SessionArtist
import Perfidy



class PostTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)
  
  
  func testPostParams() throws {
    try doFakePost("/test", json: ["foo": "bar"], headers: [:]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Content-Type"], "application/json")
      XCTAssertEqual(req.httpBody, "{\"foo\":\"bar\"}".data(using: .utf8))
    }
  }

  
  func testPostEmptyParams() throws {
    try doFakePost("/test", json: [:], headers: [:]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Content-Type"], "application/json")
      XCTAssertEqual(req.httpBody, "{}".data(using: .utf8))
    }
  }

  
  func testPostHeaders() throws {
    try doFakePost("/test", json: [:], headers: [.accept: "foobar"]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Accept"], "foobar")
    }
  }
}



private extension PostTests {
  func doFakePost(_ path: String, json: JSONObject, headers: [HTTPHeaderField: String], postHandler: @escaping (URLRequest)->Void) throws {
    let expectedRequest = expectation(description: "waiting for request")
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add(Route(method: .post, path: path)) { req in
      postHandler(req)
      expectedRequest.fulfill()
    }
      
    let validJSON = try! ValidJSONObject(json)
    fakeHost.post(path, json: validJSON, headers: headers).data { res in
      if case .success((.ok, _, _)) = res {
        expectedResponse.fulfill()
      }
    }
    
    wait(for: [expectedRequest, expectedResponse], timeout: 1)
  }
}

import Foundation
import XCTest
import SessionArtist
import Perfidy



class DeleteTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)
  
  
  func testDelete() throws {
    let expectedRequest = expectation(description: "waiting for request")
    let expectedResponse = expectation(description: "waiting for response")

    let server = try FakeServer()
    defer { server.stop() }
    server.add(Route(method: .delete, path: "/test")) { req in
      XCTAssert(true, "endpoint exists")
      expectedRequest.fulfill()
    }
      
    fakeHost.delete("/test").data { res in
      if case .success((.ok, _, _)) = res {
        expectedResponse.fulfill()
      }
    }
    
    wait(for: [expectedRequest, expectedResponse], timeout: 10)
  }
  
  
  func testDeleteHeaders() throws {
    let expectedRequest = expectation(description: "waiting for request")
    let expectedResponse = expectation(description: "waiting for response")

    let server = try FakeServer()
    defer { server.stop() }
    server.add(Route(method: .delete, path: "/test")) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Accept"], "foobar")
      expectedRequest.fulfill()
    }
    
    fakeHost.delete("/test", headers: [.accept: "foobar"]).data { res in
      if case .success((.ok, _, _)) = res {
        expectedResponse.fulfill()
      }
    }

    wait(for: [expectedRequest, expectedResponse], timeout: 1)
  }
}

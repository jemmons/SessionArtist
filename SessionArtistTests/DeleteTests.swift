import Foundation
import XCTest
import SessionArtist
import Perfidy
import Medea



class DeleteTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)
  
  
  func testDelete() {
    doFakeDelete("/test", headers: [:]) { req in
      XCTAssert(true, "endpoint exists")
    }
  }
  
  
  func testDeleteHeaders() {
    doFakeDelete("/test", headers: [.accept: "foobar"]) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Accept"], "foobar")
    }
  }
}



private extension DeleteTests {
  func doFakeDelete(_ path: String, headers: [HTTPHeaderField: String], putHandler: @escaping (URLRequest)->Void) {
    let expectedRequest = expectation(description: "waiting for request")
    let expectedResponse = expectation(description: "waiting for response")
    
    FakeServer.runWith { server in
      server.add(Route(method: .delete, path: path)) { req in
        putHandler(req)
        expectedRequest.fulfill()
      }
      
      fakeHost.delete(path, headers: headers).data { res in
        if case .success(.ok, _, _) = res {
          expectedResponse.fulfill()
        }
      }
      
      wait(for: [expectedRequest, expectedResponse], timeout: 1)
    }
  }
}


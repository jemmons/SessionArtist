import Foundation
import XCTest
import SessionArtist
import Perfidy



class ResponseTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)
  let endpoint = Endpoint(method: .get, path: "/test")

  
  func testData() {
    let expectedResponse = expectation(description: "waiting for response")
    
    FakeServer.runWith { server in
      server.add("/test", response: ["foo": "bar"])
      
      fakeHost.request(endpoint).data { res in
        guard case let .success(status, contentType, data) = res else {
          fatalError("not a success")
        }
        XCTAssertEqual(status, .ok)
        XCTAssertEqual(contentType, "application/json")
        XCTAssertEqual(String(data: data, encoding: .utf8), "{\"foo\":\"bar\"}")
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedResponse], timeout: 1)
    }
  }
  
  
  func testAnyJSON() {
    let expectedResponse = expectation(description: "waiting for response")
    
    FakeServer.runWith { server in
      server.add("/test", response: ["foo": "bar"])
      
      fakeHost.request(endpoint).json { res in
        guard case let .success(status, .object(json)) = res else {
          fatalError("not a success")
        }
        XCTAssertEqual(status, .ok)
        XCTAssertEqual(json as! [String: String], ["foo": "bar"])
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedResponse], timeout: 1)
    }
  }
  
  
  func testJSONObject() {
    let expectedResponse = expectation(description: "waiting for response")
    
    FakeServer.runWith { server in
      server.add("/test", response: ["foo": "bar"])
      
      fakeHost.request(endpoint).jsonObject { res in
        guard case let .success(status, json) = res else {
          fatalError("not a success")
        }
        XCTAssertEqual(status, .ok)
        XCTAssertEqual(json as! [String: String], ["foo": "bar"])
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedResponse], timeout: 1)
    }
  }
  
  
  func testJSONObjectFailure() {
    let expectedResponse = expectation(description: "waiting for response")
    
    FakeServer.runWith { server in
      server.add("/test", response: "foo")
      
      fakeHost.request(endpoint).jsonObject { res in
        guard case .failure = res else {
          fatalError("expected to fail")
        }
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedResponse], timeout: 1)
    }
  }
  
  
  func testJSONArray() {
    let expectedResponse = expectation(description: "waiting for response")
    
    FakeServer.runWith { server in
      server.add("/test", response: try! Response(jsonArray:["foo", "bar"]))
      
      fakeHost.request(endpoint).jsonArray { res in
        guard case let .success(status, json) = res else {
          fatalError("not a success")
        }
        XCTAssertEqual(status, .ok)
        XCTAssertEqual(json as! [String], ["foo", "bar"])
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedResponse], timeout: 1)
    }
  }
  
  
  func testJSONArrayFailure() {
    let expectedResponse = expectation(description: "waiting for response")
    
    FakeServer.runWith { server in
      server.add("/test", response: "foo")
      
      fakeHost.request(endpoint).jsonArray { res in
        guard case .failure = res else {
          fatalError("expected to fail")
        }
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedResponse], timeout: 1)
    }
  }
}


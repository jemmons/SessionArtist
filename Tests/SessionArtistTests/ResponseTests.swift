import Foundation
import XCTest
import SessionArtist
import Perfidy



class ResponseTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)
  let endpoint = Endpoint(method: .get, path: "/test")
  
  
  func testData() throws {
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/test", response: ["foo": "bar"])
    
    fakeHost.request(endpoint).data { res in
      guard case let .success((status, contentType, data)) = res else {
        fatalError("not a success")
      }
      XCTAssertEqual(status, .ok)
      XCTAssertEqual(contentType, "application/json")
      XCTAssertEqual(String(data: data, encoding: .utf8), "{\"foo\":\"bar\"}")
      expectedResponse.fulfill()
    }
    
    wait(for: [expectedResponse], timeout: 1)
  }
  
  
  
  
  func testJSONObject() throws {
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/test", response: ["foo": "bar"])
    
    fakeHost.request(endpoint).jsonObject { res in
      guard case let .success((status, json)) = res else {
        fatalError("not a success")
      }
      XCTAssertEqual(status, .ok)
      XCTAssertEqual(json as! [String: String], ["foo": "bar"])
      expectedResponse.fulfill()
    }
    
    wait(for: [expectedResponse], timeout: 1)
  }
  
  
  
  
  func testJSONObjectFailure() throws {
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/test", response: "foo")
    
    fakeHost.request(endpoint).jsonObject { res in
      guard case .failure = res else {
        fatalError("expected to fail")
      }
      expectedResponse.fulfill()
    }
    
    wait(for: [expectedResponse], timeout: 1)
  }
  
  
  
  
  func testJSONArray() throws {
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/test", response: try! Response(jsonArray:["foo", "bar"]))
    
    fakeHost.request(endpoint).jsonArray { res in
      guard case let .success((status, json)) = res else {
        fatalError("not a success")
      }
      XCTAssertEqual(status, .ok)
      XCTAssertEqual(json as! [String], ["foo", "bar"])
      expectedResponse.fulfill()
    }
    
    wait(for: [expectedResponse], timeout: 1)
  }
  
  
  
  
  func testJSONArrayFailure() throws {
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
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

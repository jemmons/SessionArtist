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
  
  
  func testAsyncData() async throws {
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/test", response: ["foo": "bar"])
    
    let (status, contentType, data) = try await fakeHost.request(endpoint).data()
    XCTAssertEqual(status, .ok)
    XCTAssertEqual(contentType, "application/json")
    XCTAssertEqual(String(data: data, encoding: .utf8), "{\"foo\":\"bar\"}")
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
  
  
  func testAsyncJSONObject() async throws {
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/test", response: ["foo": "bar"])
    
    let (status, json) = try await fakeHost.request(endpoint).jsonObject()
    XCTAssertEqual(status, .ok)
    XCTAssertEqual(json as! [String: String], ["foo": "bar"])
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
  
  
  func testAsyncJSONObjectFailure() async throws {
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/array", response: "[]")
    server.add("/not-json", response: "not-json")
    let arrayEndpoint = Endpoint(method: .get, path: "/array")
    let notJSONEndpoint = Endpoint(method: .get, path: "/not-json")
    
    do {
      _ = try await fakeHost.request(arrayEndpoint).jsonObject()
      XCTFail("Should have thrown")
    } catch APIError.notJSONObject {
      XCTAssert(true)
    } catch {
      XCTFail("Should have throw specific error.")
    }
    
    do {
      _ = try await fakeHost.request(notJSONEndpoint).jsonObject()
      XCTFail("Should have thrown")
    } catch CocoaError.propertyListReadCorrupt {
      XCTAssert(true)
    } catch {
      XCTFail("Should have throw specific error.")
    }
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
  
  
  func testAsyncJSONArray() async throws {
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/test", response: try! Response(jsonArray:["foo", "bar"]))
    
    let (status, json) = try await fakeHost.request(endpoint).jsonArray()
    XCTAssertEqual(status, .ok)
    XCTAssertEqual(json as! [String], ["foo", "bar"])
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
  
  
  func testAsyncJSONArrayFailure() async throws {
    let server = try FakeServer()
    defer { server.stop() }
    server.add("/object", response: "{}")
    server.add("/not-json", response: "not-json")
    let objectEndpoint = Endpoint(method: .get, path: "/object")
    let notJSONEndpoint = Endpoint(method: .get, path: "/not-json")
    
    do {
      _ = try await fakeHost.request(objectEndpoint).jsonArray()
      XCTFail("Should have thrown")
    } catch APIError.notJSONArray {
      XCTAssert(true)
    } catch {
      XCTFail("Should have throw specific error.")
    }
    
    do {
      _ = try await fakeHost.request(notJSONEndpoint).jsonObject()
      XCTFail("Should have thrown")
    } catch CocoaError.propertyListReadCorrupt {
      XCTAssert(true)
    } catch {
      XCTFail("Should have throw specific error.")
    }
  }
}

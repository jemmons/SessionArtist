import Foundation
import XCTest
import SessionArtist
import Perfidy



class RequestTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL, defaultHeaders: [.other("foo"): "bar"])
  
  
  func testRequestHeaders() throws {
    let endpoint = Endpoint(method: .get, path: "/test", headers: [.other("baz"): "thud"])
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertEqual("bar", req.allHTTPHeaderFields!["foo"], "Host headers")
      XCTAssertEqual("thud", req.allHTTPHeaderFields!["baz"], "Endpoint headers")
    }
  }
  
  
  func testURLRequestParam() throws {
    let endpoint = Endpoint(method: .trace, path: "/test", headers: [.other("baz"): "thud"])
    let req = fakeHost.request(endpoint).urlRequest
    XCTAssert(req.url!.absoluteString.starts(with: FakeServer.defaultURL.absoluteString))
    XCTAssertEqual( "/test", req.url!.path)
    XCTAssertEqual("TRACE", req.httpMethod)
    XCTAssertEqual("bar", req.allHTTPHeaderFields!["foo"], "Host headers")
    XCTAssertEqual("thud", req.allHTTPHeaderFields!["baz"], "Endpoint headers")
  }
  
  
  func testRequestGetEndpoint() throws {
    let params = Params([URLQueryItem(name: "foo", value: "bar")])
    let endpoint = Endpoint(method: .get, path: "/test", params: params)
    
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertEqual(req.url!.query, "foo=bar")
      XCTAssertNil(req.allHTTPHeaderFields!["Content-Type"])
    }
  }
  
  
  func testRequestPostQueryEndpoint() throws {
    let params = Params([URLQueryItem(name: "foo", value: "bar")])
    let endpoint = Endpoint(method: .postQuery, path: "/test", params: params)
    
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertEqual(req.url!.query, "foo=bar")
      XCTAssertNil(req.allHTTPHeaderFields!["Content-Type"])
    }
  }
  
  
  func testRequestPostEndpoint() throws {
    let params = Params([URLQueryItem(name: "foo", value: "bar")])
    let endpoint = Endpoint(method: .post, path: "/test", params: params)
    
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Content-Type"], "application/x-www-form-urlencoded")
      XCTAssertEqual(String(data: req.httpBody!, encoding: .utf8), "foo=bar")
      XCTAssertNil(req.url!.query)
    }
  }
  
  
  func testRequestPutEndpoint() throws {
    let params = Params([URLQueryItem(name: "foo", value: "bar")])
    let endpoint = Endpoint(method: .put, path: "/test", params: params)
    
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Content-Type"], "application/x-www-form-urlencoded")
      XCTAssertEqual(String(data: req.httpBody!, encoding: .utf8), "foo=bar")
      XCTAssertNil(req.url!.query)
    }
  }
  
  
  func testRequestDeleteEndpoint() throws {
    let endpoint = Endpoint(method: .delete, path: "/test")
    
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertNil(req.url!.query)
      XCTAssertNil(req.httpBody)
    }
  }
  
  
  func testOverrideContentType() throws {
    let params = Params([URLQueryItem(name: "foo", value: "bar")])
    let endpoint = Endpoint(method: .post, path: "/test", params: params, headers: [.contentType: "foobar"])
    
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertEqual(req.allHTTPHeaderFields!["Content-Type"], "foobar")
      XCTAssertEqual(String(data: req.httpBody!, encoding: .utf8), "foo=bar")
    }
  }
  
  
  func testGetEndpointWithoutParams() throws {
    let endpoint = Endpoint(method: .get, path: "/test")
    try doFakeRequest(endpoint: endpoint) { req in
      XCTAssertFalse(req.url!.absoluteString.contains("?"))
    }
  }

}



private extension RequestTests {
  func doFakeRequest(endpoint: Endpoint, requestHandler: @escaping (URLRequest)->Void) throws {
    let expectedRequest = expectation(description: "waiting for request")
    let expectedResponse = expectation(description: "waiting for response")
    
    let server = try FakeServer()
    defer { server.stop() }
    server.add(Route(method: endpoint.method.description, path: endpoint.path)) { req in
      requestHandler(req)
      expectedRequest.fulfill()
    }
      
    fakeHost.request(endpoint).data { res in
      if case .success((.ok, _, _)) = res {
        expectedResponse.fulfill()
      }
    }
    
    wait(for: [expectedRequest, expectedResponse], timeout: 1)
  }
}


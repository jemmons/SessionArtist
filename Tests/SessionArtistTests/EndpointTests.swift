import Foundation
import XCTest
import SessionArtist
import Medea



class EndpointTests: XCTestCase {
  //MARK: - PATH
  func testRootPath() {
    XCTAssertEqual(requestURL(endpointPath: "/", base: "http://example.com"), "http://example.com/")
    XCTAssertEqual(requestURL(endpointPath: "/", base: "http://example.com/bare"), "http://example.com/bare/")
    XCTAssertEqual(requestURL(endpointPath: "/", base: "http://example.com/slash/"), "http://example.com/slash/")
  }
  
  
  func testBarePath() {
    XCTAssertEqual(requestURL(endpointPath: "foo", base: "http://example.com"), "http://example.com/foo")
    XCTAssertEqual(requestURL(endpointPath: "foo", base: "http://example.com/bare"), "http://example.com/bare/foo")
    XCTAssertEqual(requestURL(endpointPath: "foo", base: "http://example.com/slash/"), "http://example.com/slash/foo")
  }


  func testLeadingPath() {
    XCTAssertEqual(requestURL(endpointPath: "/foo", base: "http://example.com"), "http://example.com/foo")
    XCTAssertEqual(requestURL(endpointPath: "/foo", base: "http://example.com/bare"), "http://example.com/bare/foo")
    XCTAssertEqual(requestURL(endpointPath: "/foo", base: "http://example.com/slash/"), "http://example.com/slash/foo")
  }
  
  
  func testTrailingPath() {
    XCTAssertEqual(requestURL(endpointPath: "foo/", base: "http://example.com"), "http://example.com/foo/")
    XCTAssertEqual(requestURL(endpointPath: "foo/", base: "http://example.com/bare"), "http://example.com/bare/foo/")
    XCTAssertEqual(requestURL(endpointPath: "foo/", base: "http://example.com/slash/"), "http://example.com/slash/foo/")
  }

  
  func testBookendPath() {
    XCTAssertEqual(requestURL(endpointPath: "/foo/", base: "http://example.com"), "http://example.com/foo/")
    XCTAssertEqual(requestURL(endpointPath: "/foo/", base: "http://example.com/bare"), "http://example.com/bare/foo/")
    XCTAssertEqual(requestURL(endpointPath: "/foo/", base: "http://example.com/slash/"), "http://example.com/slash/foo/")
  }

  
  func testMultiPath() {
    XCTAssertEqual(requestURL(endpointPath: "/foo/bar/baz", base: "http://example.com"), "http://example.com/foo/bar/baz")
    XCTAssertEqual(requestURL(endpointPath: "/foo/bar/baz", base: "http://example.com/bare"), "http://example.com/bare/foo/bar/baz")
    XCTAssertEqual(requestURL(endpointPath: "/foo/bar/baz", base: "http://example.com/slash/"), "http://example.com/slash/foo/bar/baz")
  }

  
  func testFilePath() {
    XCTAssertEqual(requestURL(endpointPath: "/foo/bar/baz.zip", base: "http://example.com"), "http://example.com/foo/bar/baz.zip")
    XCTAssertEqual(requestURL(endpointPath: "/foo/bar/baz.zip", base: "http://example.com/bare"), "http://example.com/bare/foo/bar/baz.zip")
    XCTAssertEqual(requestURL(endpointPath: "/foo/bar/baz.zip", base: "http://example.com/slash/"), "http://example.com/slash/foo/bar/baz.zip")
  }
  
  
  //MARK: - METHOD
  func testMethods() {
    let url = URL(string: "http://example.com")!
    let getReq = Endpoint(method: .get, path: "/", params: nil, headers: [:]).request(from: url)
    XCTAssertEqual(getReq.httpMethod, "GET")

    let postReq = Endpoint(method: .post, path: "/", params: nil, headers: [:]).request(from: url)
    XCTAssertEqual(postReq.httpMethod, "POST")
    
    let putReq = Endpoint(method: .put, path: "/", params: nil, headers: [:]).request(from: url)
    XCTAssertEqual(putReq.httpMethod, "PUT")
    
    let deleteReq = Endpoint(method: .delete, path: "/", params: nil, headers: [:]).request(from: url)
    XCTAssertEqual(deleteReq.httpMethod, "DELETE")
  }
  
  
  //MARK: - PARAMS
  func testGetFormParams() {
    let items = [URLQueryItem(name: "foo", value: "bar"), URLQueryItem(name: "baz", value: "thud")]
    let params = Params(items)
    let getURLString = Endpoint(method: .get, path: "/", params: params, headers: [:]).request(from: URL(string: "http://example.com")!).url!.absoluteString
    let comps = URLComponents(string: getURLString)
    XCTAssertEqual(comps!.queryItems!, items)
  }
  
  
  func testGetJSONParams() {
    let params = try! Params(ValidJSONObject(["foo": "bar"]))
    let getURLString = Endpoint(method: .get, path: "/", params: params, headers: [:]).request(from: URL(string: "http://example.com")!).url!.absoluteString
    let comps = URLComponents(string: getURLString)
    XCTAssertEqual(comps!.queryItems!, [URLQueryItem(name: "foo", value: "bar")])
  }
  

  func testPostAndPutFormParams() {
    let items = [URLQueryItem(name: "foo", value: "bar"), URLQueryItem(name: "baz", value: "thud")]
    let params = Params(items)

    let postreq = Endpoint(method: .post, path: "/", params: params, headers: [:]).request(from: URL(string: "http://example.com")!)
    XCTAssertEqual(postreq.httpMethod, "POST")
    XCTAssertEqual(postreq.allHTTPHeaderFields!["Content-Type"], "application/x-www-form-urlencoded")
    XCTAssertEqual(postreq.httpBody, "foo=bar&baz=thud".data(using: .utf8))
    
    let putreq = Endpoint(method: .put, path: "/", params: params, headers: [:]).request(from: URL(string: "http://example.com")!)
    XCTAssertEqual(putreq.httpMethod, "PUT")
    XCTAssertEqual(putreq.allHTTPHeaderFields!["Content-Type"], "application/x-www-form-urlencoded")
    XCTAssertEqual(putreq.httpBody, "foo=bar&baz=thud".data(using: .utf8))
  }
  
  
  func testPostAndPutJSONParams() {
    let params = try! Params(ValidJSONObject(["foo": "bar"]))

    let postreq = Endpoint(method: .post, path: "/", params: params, headers: [:]).request(from: URL(string: "http://example.com")!)
    XCTAssertEqual(postreq.httpMethod, "POST")
    XCTAssertEqual(postreq.allHTTPHeaderFields!["Content-Type"], "application/json")
    XCTAssertEqual(postreq.httpBody, "{\"foo\":\"bar\"}".data(using: .utf8))

    let putreq = Endpoint(method: .put, path: "/", params: params, headers: [:]).request(from: URL(string: "http://example.com")!)
    XCTAssertEqual(putreq.httpMethod, "PUT")
    XCTAssertEqual(putreq.allHTTPHeaderFields!["Content-Type"], "application/json")
    XCTAssertEqual(putreq.httpBody, "{\"foo\":\"bar\"}".data(using: .utf8))
  }
}


private extension EndpointTests {
  func requestURL(endpointPath: String, base: String) -> String {
    return Endpoint(method: .get, path: endpointPath).request(from: URL(string: base)!).url!.absoluteString
  }
}


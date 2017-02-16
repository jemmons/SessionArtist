import Foundation
import XCTest
import SessionArtist



class HostTests: XCTestCase {
  func testJustHost() {
    let subject = try! Host(urlString: "http://example.com")
    subject.withPath(nil, equals: "http://example.com")
    subject.withPath("foo", equals: "http://example.com/foo")
    subject.withPath("/foo", equals: "http://example.com/foo")
    subject.withPath("/foo/", equals: "http://example.com/foo/")
    subject.withPath("/foo/bar", equals: "http://example.com/foo/bar")
    subject.withParams([URLQueryItem(name: "foo", value:"bar")], equals: "http://example.com?foo=bar")
  }
  
  
  func testWithPath() {
    let subject = try! Host(urlString: "http://example.com/default")
    subject.withPath(nil, equals: "http://example.com/default")
    subject.withPath("foo", equals: "http://example.com/default/foo")
    subject.withPath("/foo", equals: "http://example.com/default/foo")
    subject.withPath("/foo/", equals: "http://example.com/default/foo/")
    subject.withParams([URLQueryItem(name: "foo", value:"bar")], equals: "http://example.com/default?foo=bar")
  }

  
  func testInvalidPath() {
    let shouldThrow = expectation(description: "Throws due to bad URL")
    do {
      _ = try Host(urlString: "invalid`character")
    } catch InitializationError.invalidURL {
      shouldThrow.fulfill()
    } catch {
      XCTFail()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }
  
  
  func testWithTrailingSlash() {
    let subject = try! Host(urlString: "http://example.com/default/")
    subject.withPath(nil, equals: "http://example.com/default/")
    subject.withPath("foo", equals: "http://example.com/default/foo")
    //vv Not desireable, but also not unexpected vv
    subject.withPath("/foo", equals: "http://example.com/default//foo")
    subject.withPath("/foo/", equals: "http://example.com/default//foo/")
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    subject.withParams([URLQueryItem(name: "foo", value:"bar")], equals: "http://example.com/default/?foo=bar")
  }


  func testWithQuery() {
    let subject = try! Host(urlString: "http://example.com?key=value")
    subject.withPath(nil, equals: "http://example.com?key=value")
    subject.withPath("foo", equals: "http://example.com/foo?key=value")
    subject.withPath("/foo", equals: "http://example.com/foo?key=value")
    subject.withPath("/foo/", equals: "http://example.com/foo/?key=value")
    subject.withParams([URLQueryItem(name: "foo", value:"bar")], equals: "http://example.com?key=value&foo=bar")
    // Can't argue with the RFC :'(
    subject.withParams([URLQueryItem(name: "key", value:"otherValue")], equals: "http://example.com?key=value&key=otherValue")
  }
  

  func testWithPathAndQuery() {
    let subject = try! Host(urlString: "http://example.com/default?key=value")
    subject.withPath(nil, equals: "http://example.com/default?key=value")
    subject.withPath("foo", equals: "http://example.com/default/foo?key=value")
    subject.withPath("/foo", equals: "http://example.com/default/foo?key=value")
    subject.withPath("/foo/", equals: "http://example.com/default/foo/?key=value")
    subject.withParams([URLQueryItem(name: "foo", value:"bar")], equals: "http://example.com/default?key=value&foo=bar")
    // Can't argue with the RFC :'(
    subject.withParams([URLQueryItem(name: "key", value:"otherValue")], equals: "http://example.com/default?key=value&key=otherValue")
  }
}


private extension Host {
  func withPath(_ path: String?, equals urlString: String) {
    var req = get(path)
    XCTAssertEqual(req.url!.absoluteString, urlString)
    
    req = post(path, params: [])
    XCTAssertEqual(req.url!.absoluteString, urlString)
    
    req = put(path, params: [])
    XCTAssertEqual(req.url!.absoluteString, urlString)

    req = delete(path)
    XCTAssertEqual(req.url!.absoluteString, urlString)
    
    req = try! graph(path, query: "")
    XCTAssertEqual(req.url!.absoluteString, urlString)
  }
  
  
  func withParams(_ params: [URLQueryItem], equals urlString: String) {
    // Note only GET is tested. It's the only method that concerns itself with query parameters.
    let req = get(nil, params: params)
    XCTAssertEqual(req.url!.absoluteString, urlString)
  }
}

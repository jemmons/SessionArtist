import Foundation
import XCTest
import SessionArtist



class URLPatternMatcherTests: XCTestCase {
  func testMatchesHost() {
    switch URL(string: "http://example.com/foo")! {
    case URL.Host("example"),
         URL.Host("example.net"),
         URL.Host("www.example.com"),
         URL.Host("example.com.au"):
      XCTFail()
    case URL.Host("example.com"):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testMatchesPath() {
    switch URL(string: "http://example.com/foo")! {
    case URL.Path("/"),
         URL.Path("foo"),
         URL.Path("/foo/"):
      XCTFail()
    case URL.Path("/foo"):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testMatchesPathPrefix() {
    let subject = URL(string: "http://example.com/foo/bar")!
    guard case URL.PathPrefix("/") = subject else {
      XCTFail()
      return
    }
    
    guard case URL.PathPrefix("/foo/") = subject else {
      XCTFail()
      return
    }

    guard case URL.PathPrefix("/foo/bar") = subject else {
      XCTFail()
      return
    }

    if case URL.PathPrefix("/foo/bar/") = subject {
      XCTFail()
    }

    if case URL.PathPrefix("/foo/bar/baz") = subject {
      XCTFail()
    }

    if case URL.PathPrefix("/foo/bo") = subject {
      XCTFail()
    }
  }
}

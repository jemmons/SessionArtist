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

  
  func testMatchesComponents() {
    switch URL(string: "http://example.com/foo/bar")! {
    case URL.Path(["foo", "bar"]):
      XCTFail()
    case URL.Path(["/", "foo", "barr", "baz"]):
      XCTFail()
    case URL.Path(["/", "foo", "bar", "baz"]):
      XCTFail()
    case URL.Path(["/", "foo", "ba"]):
      XCTFail()
    case URL.Path(["/", "foo"]):
      XCTFail()
    case URL.Path(["/"]):
      XCTFail()
    case URL.Path(["/", "foo", "bar"]):
      XCTAssert(true)
    default:
      XCTFail()
    }

    guard case URL.Path(["/", "foo", "bar"]) = URL(string: "http://example.com/foo/bar/")! else {
      XCTFail()
      return
    }

    guard case URL.Path([]) = URL(string: "http://example.com")! else {
      XCTFail()
      return
    }

    if case URL.Path(["/"]) = URL(string: "http://example.com")! {
      XCTFail()
    }

    switch URL(string: "http://example.com/")! {
    case URL.Path([]):
      XCTFail()
    case URL.Path(["/"]):
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
  
  
  func testMatchesComponentsPrefix() {
    let foobar = URL(string: "http://example.com/foo/bar")!
    guard case URL.PathPrefix([]) = foobar else {
      XCTFail()
      return
    }

    guard case URL.PathPrefix(["/"]) = foobar else {
      XCTFail()
      return
    }

    guard case URL.PathPrefix(["/", "foo"]) = foobar else {
      XCTFail()
      return
    }
    
    guard case URL.PathPrefix(["/", "foo", "bar"]) = foobar else {
      XCTFail()
      return
    }
    
    if case URL.PathPrefix(["/", "foo", "barr"]) = foobar {
      XCTFail()
    }

    if case URL.PathPrefix(["/", "foo", "bar", "baz"]) = foobar {
      XCTFail()
    }
    
    if case URL.PathPrefix(["/", "foo", "ba"]) = foobar {
      XCTFail()
    }

    if case URL.PathPrefix(["foo", "bar"]) = foobar {
      XCTFail()
    }

    
    switch URL(string: "http://example.com/foo/bar/")! {
    case URL.PathPrefix(["/", "foo", "bar", "baz"]):
      XCTFail()
    
    case URL.PathPrefix(["/", "foo", "barr"]):
      XCTFail()
    
    case URL.PathPrefix(["/", "foo", "ba"]):
      XCTFail()
    
    case URL.PathPrefix(["/", "foo", "bar", "/"]):
      XCTFail()
    
    case URL.PathPrefix(["/", "foo", "bar"]):
      XCTAssert(true)
    
    default:
      XCTFail()
    }
    
    guard case URL.PathPrefix(["/"]) = URL(string: "http://example.com/")! else {
      XCTFail()
      return
    }
    
    switch URL(string: "http://example.com")! {
    case URL.PathPrefix(["/"]):
      XCTFail()
    
    case URL.PathPrefix([]):
      XCTAssert(true)
    
    default:
      XCTFail()
    }
  }
}

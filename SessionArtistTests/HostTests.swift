import Foundation
import XCTest
import SessionArtist



class HostTests: XCTestCase {
  func testURLTransparency() {
    let aURL = URL(string: "http://example.com")!
    let subject = Host(baseURL: aURL)
    XCTAssertEqual(aURL, subject.url)
  }
  
  
  func testHeaderTransparency() {
    let nilHost = Host(baseURL: URL(string: "http://example.com")!)
    XCTAssert(nilHost.headers.isEmpty)
    
    let acceptHost = Host(baseURL: URL(string: "http://example.com")!, defaultHeaders: [.accept: "foo"])
    XCTAssertEqual("foo", acceptHost.headers[.accept])
  }
  
  
  func testTimeoutTransparency() {
    let defaultHost = Host(baseURL: URL(string: "http://example.com")!)
    XCTAssertEqual(15, defaultHost.timeout)
    
    let tenHost = Host(baseURL: URL(string: "http://example.com")!, timeout: 10)
    XCTAssertEqual(10, tenHost.timeout)
  }
}

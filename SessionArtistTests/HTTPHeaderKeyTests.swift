import Foundation
import XCTest
import SessionArtist



class HTTPHeaderFieldTests: XCTestCase {
  func testKey() {
    XCTAssertEqual(HTTPHeaderField.accept.description, "Accept")
    XCTAssertEqual(HTTPHeaderField.other("foo").description, "foo")
  }
  
  func testKeyEquality() {
    XCTAssertEqual(HTTPHeaderField.accept, HTTPHeaderField.accept)
    XCTAssertNotEqual(HTTPHeaderField.accept, HTTPHeaderField.acceptCharset)
    XCTAssertEqual(HTTPHeaderField.accept, HTTPHeaderField.other("Accept"), "equality based on key value")
  }
}

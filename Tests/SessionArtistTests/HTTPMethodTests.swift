import Foundation
import XCTest
import SessionArtist



class HTTPMethodTests: XCTestCase {
  func testEquality () {
    XCTAssertEqual(HTTPMethod.post, HTTPMethod.post)
    XCTAssertNotEqual(HTTPMethod.post, HTTPMethod.put)
    XCTAssertNotEqual(HTTPMethod.post, HTTPMethod.postQuery)
  }
  
  
  func testFromMinusculeString() {
    XCTAssertEqual(HTTPMethod(string: "get"), .get)
    XCTAssertEqual(HTTPMethod(string: "post"), .post)
    XCTAssertEqual(HTTPMethod(string: "put"), .put)
    XCTAssertEqual(HTTPMethod(string: "patch"), .patch)
    XCTAssertEqual(HTTPMethod(string: "delete"), .delete)
    XCTAssertEqual(HTTPMethod(string: "connect"), .connect)
    XCTAssertEqual(HTTPMethod(string: "head"), .head)
    XCTAssertEqual(HTTPMethod(string: "trace"), .trace)
    XCTAssertEqual(HTTPMethod(string: "options"), .options)
  }
  
  
  func testFromMajusculeString() {
    XCTAssertEqual(HTTPMethod(string: "GET"), .get)
    XCTAssertEqual(HTTPMethod(string: "POST"), .post)
    XCTAssertEqual(HTTPMethod(string: "PUT"), .put)
    XCTAssertEqual(HTTPMethod(string: "PATCH"), .patch)
    XCTAssertEqual(HTTPMethod(string: "DELETE"), .delete)
    XCTAssertEqual(HTTPMethod(string: "CONNECT"), .connect)
    XCTAssertEqual(HTTPMethod(string: "HEAD"), .head)
    XCTAssertEqual(HTTPMethod(string: "TRACE"), .trace)
    XCTAssertEqual(HTTPMethod(string: "OPTIONS"), .options)
  }
  
  
  func testWeirdnessAroundPostQuery() {
    let postQuery = HTTPMethod.postQuery
    let fromString = HTTPMethod(string: postQuery.description)
    XCTAssertNotEqual(fromString, .postQuery)
    XCTAssertEqual(fromString, .post)
  }
}

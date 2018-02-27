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
    XCTAssertEqual(HTTPHeaderField.other("foo"), HTTPHeaderField.other("foo"))
    XCTAssertEqual(HTTPHeaderField.other("FOO"), HTTPHeaderField.other("foo"))
    XCTAssertEqual(HTTPHeaderField.accept, HTTPHeaderField.other("Accept"))
    XCTAssertEqual(HTTPHeaderField.accept, HTTPHeaderField.other("ACCEPT"))
  }
  
  
  func testCommutativeProperty() {
    XCTAssertEqual("Accept", HTTPHeaderField.accept)
    XCTAssertEqual("Accept", HTTPHeaderField.accept.description)
    XCTAssertEqual("Accept-Charset", HTTPHeaderField.acceptCharset)
    XCTAssertEqual("Accept-Charset", HTTPHeaderField.acceptCharset.description)
    XCTAssertEqual("Accept-Encoding", HTTPHeaderField.acceptEncoding)
    XCTAssertEqual("Accept-Encoding", HTTPHeaderField.acceptEncoding.description)
    XCTAssertEqual("Accept-Language", HTTPHeaderField.acceptLanguage)
    XCTAssertEqual("Accept-Language", HTTPHeaderField.acceptLanguage.description)
    XCTAssertEqual("Accept-Version", HTTPHeaderField.acceptVersion)
    XCTAssertEqual("Accept-Version", HTTPHeaderField.acceptVersion.description)
    XCTAssertEqual("Authorization", HTTPHeaderField.authorization)
    XCTAssertEqual("Authorization", HTTPHeaderField.authorization.description)
    XCTAssertEqual("Cache-Control", HTTPHeaderField.cacheControl)
    XCTAssertEqual("Cache-Control", HTTPHeaderField.cacheControl.description)
    XCTAssertEqual("Connection", HTTPHeaderField.connection)
    XCTAssertEqual("Connection", HTTPHeaderField.connection.description)
    XCTAssertEqual("Cookie", HTTPHeaderField.cookie)
    XCTAssertEqual("Cookie", HTTPHeaderField.cookie.description)
    XCTAssertEqual("Content-Length", HTTPHeaderField.contentLength)
    XCTAssertEqual("Content-Length", HTTPHeaderField.contentLength.description)
    XCTAssertEqual("Content-MD5", HTTPHeaderField.contentMD5)
    XCTAssertEqual("Content-MD5", HTTPHeaderField.contentMD5.description)
    XCTAssertEqual("Content-Type", HTTPHeaderField.contentType)
    XCTAssertEqual("Content-Type", HTTPHeaderField.contentType.description)
    XCTAssertEqual("Date", HTTPHeaderField.date)
    XCTAssertEqual("Date", HTTPHeaderField.date.description)
    XCTAssertEqual("Host", HTTPHeaderField.host)
    XCTAssertEqual("Host", HTTPHeaderField.host.description)
    XCTAssertEqual("Origin", HTTPHeaderField.origin)
    XCTAssertEqual("Origin", HTTPHeaderField.origin.description)
    XCTAssertEqual("Referer", HTTPHeaderField.referer)
    XCTAssertEqual("Referer", HTTPHeaderField.referer.description)
    XCTAssertEqual("User-Agent", HTTPHeaderField.userAgent)
    XCTAssertEqual("User-Agent", HTTPHeaderField.userAgent.description)
    XCTAssertEqual("RandomThing", HTTPHeaderField.other("RandomThing"))
    XCTAssertEqual("RandomThing", HTTPHeaderField.other("RandomThing").description)
  }
}

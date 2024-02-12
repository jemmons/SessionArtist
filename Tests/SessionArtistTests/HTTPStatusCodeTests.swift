import Foundation
import XCTest
import SessionArtist



class HTTPStatusCodeTests: XCTestCase {
  let subject = HTTPStatusCode.ok


  func testIntegerMatching() {
    switch subject {
    case 200:
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testOpenRangeMatching() {
    switch subject {
    case 199...200:
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testClosedRangeMatching() {
    switch subject {
    case 199..<201:
      XCTAssert(true)
    default: XCTFail()
    }
  }
  
  
  func testConstantRanges() {
    switch subject {
    case HTTPStatusCode.successRange:
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testPredicate() {
    XCTAssert(subject.isSuccess)
    XCTAssertFalse(subject.isInformational)
    XCTAssertFalse(subject.isRedirection)
    XCTAssertFalse(subject.isClientError)
    XCTAssertFalse(subject.isServerError)
    
    
    XCTAssert(HTTPStatusCode.continue.isInformational)
    XCTAssert(HTTPStatusCode.found.isRedirection)
    XCTAssert(HTTPStatusCode.notFound.isClientError)
    XCTAssert(HTTPStatusCode.badGateway.isServerError)
  }
}

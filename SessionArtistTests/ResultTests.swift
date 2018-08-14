import Foundation
import XCTest
import SessionArtist



class ResultTests: XCTestCase {
  let success = Result<Int>.success(42)
  let failure = Result<Int>.failure(E.original)


  enum E: Error {
    case original
    case new
  }
  
  
  func testInitializer() {
    switch Result("foo") {
    case .success("foo"):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    switch Result<String>(E.original) {
    case .failure(E.original):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testFlatMapToSuccess() {
    switch success.flatMap(transform: {.success(String($0))}) {
    case .success("42"):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    switch failure.flatMap(transform: {.success(String($0))}) {
    case .failure(E.original):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testFlatMapToFailure() {
    switch success.flatMap(transform: {_ in Result<String>.failure(E.new)}) {
    case .failure(E.new):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    switch failure.flatMap(transform: {_ in Result<String>.failure(E.new)}) {
    case .failure(E.original):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  

  func testFlatMapThrows() {
    switch success.flatMap(transform: {_ -> Result<String> in throw(E.new) }) {
    case .failure(E.new):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    switch failure.flatMap(transform: {_ -> Result<String> in throw(E.new) }) {
    case .failure(E.original):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }

  
  func testMap() {
    switch success.map(transform: { String($0) }) {
    case .success("42"):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    switch failure.map(transform: { String($0) }) {
    case .failure(E.original):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testVoidResult() {
    //Closures to hide XCTest warnings about constants.
    let voidSuccess = { Result<Void>.success(()) }
    let voidFailure = { Result<Void>.failure(E.original) }
    
    switch voidSuccess() {
    //We wouldn't care about the associated value in practice. We only check for `()` for completeness's sake.
    case .success(()):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    switch voidFailure() {
    case .failure(E.original):
      XCTAssert(true)
    default:
      XCTFail()
    }
  }


  func testResolve() {
    try! XCTAssertEqual(success.resolve(), 42)
    
    do {
      _ = try failure.resolve()
      XCTFail()
    } catch E.original {
      XCTAssert(true)
    } catch {
      XCTFail()
    }
  }
}

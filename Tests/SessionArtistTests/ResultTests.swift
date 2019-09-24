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
  
  
  func testPredicates() {
    XCTAssert(success.isSuccess)
    XCTAssert(failure.isFailure)
    XCTAssertFalse(success.isFailure)
    XCTAssertFalse(failure.isSuccess)
  }
  
  
  func testInitializer() {
    switch Result.success("foo") {
    case .success("foo"):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    switch Result<String>.failure(E.original) {
    case .failure(E.original):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    let stringJSON = try! JSONEncoder().encode(["fourty-two"])
    let success = Result<[String]> {
      return try JSONDecoder().decode([String].self, from: stringJSON)
    }
    switch success {
    case .success(["fourty-two"]):
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    let numberJSON = try! JSONEncoder().encode([42])
    let failure = Result<[String]> {
      return try PropertyListDecoder().decode([String].self, from: numberJSON)
    }
    switch failure {
    case .failure(DecodingError.dataCorrupted):
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

  
  func testAsyncFlatMapToSuccess() {
    let expectedSuccessFromSuccess = expectation(description: "Waiting for successful result")
    let expectedFailureFromFailure = expectation(description: "Waiting for failure result")

    let transform: (Int, (Result<String>)->Void)->Void = { i, completion in
      completion(.success(String(i)))
    }
    
    success.asyncFlatMap(asyncTransform: transform) { res in
      switch res {
      case .success("42"):
        expectedSuccessFromSuccess.fulfill()
      default:
        XCTFail()
      }
    }
    
    failure.asyncFlatMap(asyncTransform: transform) { res in
      switch res {
      case .failure(E.original):
        expectedFailureFromFailure.fulfill()
      default:
        XCTFail()
      }
    }
    
    wait(for: [expectedSuccessFromSuccess, expectedFailureFromFailure], timeout: 0)
  }
  
  
  func testAsyncFlatMapToFailure() {
    let expectedFailureFromSuccess = expectation(description: "Waiting for new failure")
    let expectedFailureFromFailure = expectation(description: "Waiting for originnal failure")
    
    let transform: (Int, (Result<String>)->Void)->Void = { i, completion in
      completion(.failure(E.new))
    }
    
    success.asyncFlatMap(asyncTransform: transform) { res in
      switch res {
      case .failure(E.new):
        expectedFailureFromSuccess.fulfill()
      default:
        XCTFail()
      }
    }
    
    failure.asyncFlatMap(asyncTransform: transform) { res in
      switch res {
      case .failure(E.original):
        expectedFailureFromFailure.fulfill()
      default:
        XCTFail()
      }
    }
    
    wait(for: [expectedFailureFromSuccess, expectedFailureFromFailure], timeout: 0)
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
  
  
  func testFlatRouteToSuccess() {
    let expectedSuccessFromSuccess = expectation(description: "Waiting for success.")
    let expectedFailureFromFailure = expectation(description: "Waiting for failure.")

    let successContinuation: (Result<String>)->Void = { res in
      switch res {
      case .success("42"):
        expectedSuccessFromSuccess.fulfill()
      default:
        XCTFail()
      }
    }
    
    let failureContinuation: (Result<String>)->Void = { res in
      switch res {
      case .failure(E.original):
        expectedFailureFromFailure.fulfill()
      default:
        XCTFail()
      }
    }
    
    let adaptor: (Int)->Result<String> = { i in
      return .success(String(i))
    }
    
    Result.flatRoute(continuation: successContinuation, adaptor: adaptor)(success)
    Result.flatRoute(continuation: failureContinuation, adaptor: adaptor)(failure)

    wait(for: [expectedSuccessFromSuccess, expectedFailureFromFailure], timeout: 0)
  }
  
  
  func testFlatRouteToFailure() {
    let expectedFailureFromSuccess = expectation(description: "Waiting for failure from success.")
    let expectedFailureFromFailure = expectation(description: "Waiting for failure.")
    
    let successContinuation: (Result<String>)->Void = { res in
      switch res {
      case .failure(E.new):
        expectedFailureFromSuccess.fulfill()
      default:
        XCTFail()
      }
    }
    
    let failureContinuation: (Result<String>)->Void = { res in
      switch res {
      case .failure(E.original):
        expectedFailureFromFailure.fulfill()
      default:
        XCTFail()
      }
    }
    
    let adaptor: (Int)->Result<String> = { i in
      return .failure(E.new)
    }
    
    Result.flatRoute(continuation: successContinuation, adaptor: adaptor)(success)
    Result.flatRoute(continuation: failureContinuation, adaptor: adaptor)(failure)
    
    wait(for: [expectedFailureFromSuccess, expectedFailureFromFailure], timeout: 0)
  }
  
  
  func testAsyncFlatRouteToSuccess() {
    let expectedSuccessFromSuccess = expectation(description: "Waiting for success.")
    let expectedFailureFromFailure = expectation(description: "Waiting for failure.")
    
    let successContinuation: (Result<String>)->Void = { res in
      switch res {
      case .success("42"):
        expectedSuccessFromSuccess.fulfill()
      default:
        XCTFail()
      }
    }
    
    let failureContinuation: (Result<String>)->Void = { res in
      switch res {
      case .failure(E.original):
        expectedFailureFromFailure.fulfill()
      default:
        XCTFail()
      }
    }
    
    let adaptor: (Int, (Result<String>)->Void)->Void = { i, completion in
      completion(.success(String(i)))
    }
    
    Result.asyncFlatRoute(continuation: successContinuation, asyncAdaptor: adaptor)(success)
    Result.asyncFlatRoute(continuation: failureContinuation, asyncAdaptor: adaptor)(failure)
    
    wait(for: [expectedSuccessFromSuccess, expectedFailureFromFailure], timeout: 0)
  }
  
  
  func testAsyncFlatRouteToFailure() {
    let expectedFailureFromSuccess = expectation(description: "Waiting for failure from success.")
    let expectedFailureFromFailure = expectation(description: "Waiting for failure.")
    
    let successContinuation: (Result<String>)->Void = { res in
      switch res {
      case .failure(E.new):
        expectedFailureFromSuccess.fulfill()
      default:
        XCTFail()
      }
    }
    
    let failureContinuation: (Result<String>)->Void = { res in
      switch res {
      case .failure(E.original):
        expectedFailureFromFailure.fulfill()
      default:
        XCTFail()
      }
    }
    
    let adaptor: (Int, (Result<String>)->Void)->Void = { i, completion in
      completion(.failure(E.new))
    }
    
    Result.asyncFlatRoute(continuation: successContinuation, asyncAdaptor: adaptor)(success)
    Result.asyncFlatRoute(continuation: failureContinuation, asyncAdaptor: adaptor)(failure)
    
    wait(for: [expectedFailureFromSuccess, expectedFailureFromFailure], timeout: 0)
  }
}

import Foundation
import XCTest
import SessionArtist
import Medea



class ParamsTests: XCTestCase {
  func testForm() {
    let subject = Params.form([
      URLQueryItem(name: "foo", value: "bar"),
      URLQueryItem(name: "baz", value: nil)
      ])
    
    XCTAssertEqual(subject.makeQuery(), [
      URLQueryItem(name: "foo", value: "bar"),
      URLQueryItem(name: "baz", value: nil)
      ])
    
    XCTAssertEqual(subject.makeData(), "foo=bar&baz".data(using: .utf8))
    
    XCTAssertEqual(subject.contentType, [HTTPHeaderField.contentType: "application/x-www-form-urlencoded"])
  }
  
  
  func testJSON() {
    let json = try! ValidJSONObject([
      "foo": "bar",
      "array": [1, 2, 3],
      "hash": ["a": [1,2], "b": [3,4]]
      ])
    let subject = Params.json(json)
    
    let query = subject.makeQuery()
    XCTAssert(query.contains { $0.name == "foo" && $0.value == "bar" })
    XCTAssert(query.contains { $0.name == "array[]" && $0.value == "1" })
    XCTAssert(query.contains { $0.name == "array[]" && $0.value == "2" })
    XCTAssert(query.contains { $0.name == "array[]" && $0.value == "3" })
    XCTAssert(query.contains { $0.name == "hash[a][]" && $0.value == "1" })
    XCTAssert(query.contains { $0.name == "hash[a][]" && $0.value == "2" })
    XCTAssert(query.contains { $0.name == "hash[b][]" && $0.value == "3" })
    XCTAssert(query.contains { $0.name == "hash[b][]" && $0.value == "4" })
    
    let dataString = String(data: subject.makeData(), encoding: .utf8)!
    XCTAssertNotNil(dataString.range(of: "\"foo\":\"bar\""))
    XCTAssertNotNil(dataString.range(of: "\"array\":[1,2,3]"))
    XCTAssertNotNil(dataString.range(of: "\"hash\":{"))
    XCTAssertNotNil(dataString.range(of: "\"a\":[1,2]"))
    XCTAssertNotNil(dataString.range(of: "\"b\":[3,4]"))
    
    XCTAssertEqual(subject.contentType, [HTTPHeaderField.contentType: "application/json"])
  }
}

import Foundation
import XCTest
import SessionArtist



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
    
    XCTAssertEqual(String(data: subject.makeData(), encoding: .utf8), "foo=bar&baz")
    
    XCTAssertEqual(subject.contentType, [HTTPHeaderField.contentType: "application/x-www-form-urlencoded"])
  }

  
  func testFormURLEncoding() {
    let subject = Params.form([
      URLQueryItem(name: "space", value: "f o o"),
      URLQueryItem(name: "and", value: "f&o"),
      // Should question mark be allowed? It’s technically a delimiter, but *between* the URL and the query string. It ought to be able to appear *in* the query just fine. And, of course, wouldn't cause any ambiguity in an `x-www-form-urlencoded` body... so I’m defering to `URLComponents`’s experience in these matters.
      URLQueryItem(name: "unescaped", value: "-._~?"),
      ])
        
    XCTAssertEqual(String(data: subject.makeData(), encoding: .utf8), "space=f%20o%20o&and=f%26o&unescaped=-._~?")
  }
  
  
  func testJSON() {
    let json = try! ValidJSONObject([
      "foo": "bar",
      "array": [1, 2, 3],
      "hash": ["a": [1,2], "b": [3,4]]
      ])
    let subject = Params.json(json)
    
    let query = subject.makeQuery()
    XCTAssert(query.contains(URLQueryItem(name: "foo", value: "bar")))
    XCTAssert(query.contains(URLQueryItem(name: "array[]", value: "1")))
    XCTAssert(query.contains(URLQueryItem(name: "array[]", value: "2")))
    XCTAssert(query.contains(URLQueryItem(name: "array[]", value: "3")))
    XCTAssert(query.contains(URLQueryItem(name: "hash[a][]", value: "1")))
    XCTAssert(query.contains(URLQueryItem(name: "hash[a][]", value: "2")))
    XCTAssert(query.contains(URLQueryItem(name: "hash[b][]", value: "3")))
    XCTAssert(query.contains(URLQueryItem(name: "hash[b][]", value: "4")))
    
    let dataString = String(data: subject.makeData(), encoding: .utf8)!
    XCTAssertNotNil(dataString.range(of: "\"foo\":\"bar\""))
    XCTAssertNotNil(dataString.range(of: "\"array\":[1,2,3]"))
    XCTAssertNotNil(dataString.range(of: "\"hash\":{"))
    XCTAssertNotNil(dataString.range(of: "\"a\":[1,2]"))
    XCTAssertNotNil(dataString.range(of: "\"b\":[3,4]"))
    
    XCTAssertEqual(subject.contentType, [HTTPHeaderField.contentType: "application/json"])
  }
}

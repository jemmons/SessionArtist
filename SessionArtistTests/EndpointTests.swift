import Foundation
import XCTest
import SessionArtist



private enum DefaultEndpoint: Endpoint {
  static let host = "example.com"
  
  case getEndpoint, postEndpoint, putEndpoint, deleteEndpoint
  
  var request: URLRequest {
    switch self {
    case .getEndpoint:
      return get("/")
    case .postEndpoint:
      return post("/", params: [])
    case .putEndpoint:
      return put("/", params: [])
    case .deleteEndpoint:
      return delete("/")
    }
  }
}


private enum ParamsEndpoint: Endpoint {
  static let host = "example.com"
  case  withQuery(name: String, age: Int), postForm(name: String, age: Int), putForm(name: String, age: Int)

  var request: URLRequest {
    switch self {
    case let .withQuery(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return get("/params", params: params)
    case let .postForm(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return post("/params", params: params)
    case let .putForm(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return put("/params", params: params)
    }
  }
}


private enum JSONEndpoint: Endpoint {
  static let host = "example.com"
  case postJSON(name: String, age: Int), putJSON(name: String, age: Int)
  
  var request: URLRequest {
    switch self {
    case let .postJSON(name, age):
      return try! post("/json", json: ["name": name, "age": age])
    case let .putJSON(name, age):
      return try! put("/json", json: ["name": name, "age": age])
    }
  }
}


private enum InsecureEndpoint: Endpoint {
  static let host = "example.com"
  static let scheme = "http"
  
  case anEndpoint
  
  var request: URLRequest {
    return get("/")
  }
}



private enum PerfidyEndpoint: Endpoint {
  static let host = "localhost"
  static let scheme = "http"
  static let port = 10175
  
  case anEndpoint
  
  var request: URLRequest {
    return get("/")
  }
}



class EndpointTests: XCTestCase {
  func testDefaultEndpoint() {
    let get = DefaultEndpoint.getEndpoint.request
    XCTAssertEqual(get.url!.absoluteString, "https://example.com/")
    XCTAssertEqual(get.httpMethod, "GET")
    
    let post = DefaultEndpoint.postEndpoint.request
    XCTAssertEqual(post.httpMethod, "POST")

    let put = DefaultEndpoint.putEndpoint.request
    XCTAssertEqual(put.httpMethod, "PUT")

    let delete = DefaultEndpoint.deleteEndpoint.request
    XCTAssertEqual(delete.httpMethod, "DELETE")
  }


  func testInsecureEndpoint() {
    let subject = InsecureEndpoint.anEndpoint.request
    XCTAssertEqual(subject.url!.absoluteString, "http://example.com/")
  }


  func testQueryParams() {
    let subject = ParamsEndpoint.withQuery(name: "foo", age: 42).request
    XCTAssertEqual(subject.url!.absoluteString, "https://example.com/params?name=foo&age=42")
  }

  
  func testFormParams() {
    var subject: URLRequest
    subject = ParamsEndpoint.postForm(name: "foo", age: 42).request
    XCTAssertEqual(subject.url!.absoluteString, "https://example.com/params")
    XCTAssertEqual(subject.httpMethod, "POST")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "name=foo&age=42")
    
    subject = ParamsEndpoint.putForm(name: "bar", age: 64).request
    XCTAssertEqual(subject.url!.absoluteString, "https://example.com/params")
    XCTAssertEqual(subject.httpMethod, "PUT")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "name=bar&age=64")
  }
  
  
  func testJSONParams() {
    var subject: URLRequest
    subject = JSONEndpoint.postJSON(name: "foo", age: 42).request
    XCTAssertEqual(subject.url!.absoluteString, "https://example.com/json")
    XCTAssertEqual(subject.httpMethod, "POST")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/json")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "{\"name\":\"foo\",\"age\":42}")
    
    subject = JSONEndpoint.putJSON(name: "bar", age: 64).request
    XCTAssertEqual(subject.url!.absoluteString, "https://example.com/json")
    XCTAssertEqual(subject.httpMethod, "PUT")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/json")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "{\"name\":\"bar\",\"age\":64}")
  }
  
  
  func testPerfidyEndpoint() {
    let subject = PerfidyEndpoint.anEndpoint.request
    XCTAssertEqual(subject.url!.absoluteString, "http://localhost:10175/")
  }
}

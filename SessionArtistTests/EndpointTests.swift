import Foundation
import XCTest
import SessionArtist



private enum DefaultEndpoint: Endpoint {
  case getEndpoint, postEndpoint, putEndpoint, deleteEndpoint
  
  func makeRequest(host: Host) -> URLRequest {
    switch self {
    case .getEndpoint:
      return host.get("/")
    case .postEndpoint:
      return host.post("/", params: [])
    case .putEndpoint:
      return host.put("/", params: [])
    case .deleteEndpoint:
      return host.delete("/")
    }
  }
}



private enum DataEndpoint: Endpoint {
  case postData, putData
  
  func makeRequest(host: Host) -> URLRequest {
    switch self {
    case .postData:
      return host.post("/", data: "post".data(using: .utf8))
    case .putData:
      return host.post("/", data: "put".data(using: .utf8))
    }
  }
}



private enum ParamsEndpoint: Endpoint {
  case  withQuery(name: String, age: Int), postForm(name: String, age: Int), putForm(name: String, age: Int), postCustomContent, putCustomContent

  func makeRequest(host: Host) -> URLRequest {
    switch self {
    case let .withQuery(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return host.get("/params", params: params)
    case let .postForm(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return host.post("/params", params: params)
    case let .putForm(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return host.put("/params", params: params)
    case .postCustomContent:
      return host.post("/params", params: [], headers: ["Content-Type": "foo/bar"])
    case .putCustomContent:
      return host.put("/params", params: [], headers: ["Content-Type": "baz/quux"])

    }
  }
}


private enum JSONEndpoint: Endpoint {
  case postJSON(name: String, age: Int), putJSON(name: String, age: Int), postCustomContent, putCustomContent
  
  func makeRequest(host: Host) -> URLRequest {
    switch self {
    case let .postJSON(name, age):
      return try! host.post("/json", json: ["name": name, "age": age])
    case let .putJSON(name, age):
      return try! host.put("/json", json: ["name": name, "age": age])
    case .postCustomContent:
      return try! host.post("/json", json: ["foo": "bar"], headers: ["Content-Type": "foo/bar"])
    case .putCustomContent:
      return try! host.put("/json", json: ["foo": "bar"], headers: ["Content-Type": "baz/quux"])
    }
  }
}



class EndpointTests: XCTestCase {
  let defaultHost = Host(url: URL(string: "http://example.com")!)

  
  func testDefaultEndpoint() {
    let get = DefaultEndpoint.getEndpoint.makeRequest(host: defaultHost)
    XCTAssertEqual(get.url!.absoluteString, "http://example.com/")
    XCTAssertEqual(get.httpMethod, "GET")
    
    let post = DefaultEndpoint.postEndpoint.makeRequest(host: defaultHost)
    XCTAssertEqual(post.httpMethod, "POST")

    let put = DefaultEndpoint.putEndpoint.makeRequest(host: defaultHost)
    XCTAssertEqual(put.httpMethod, "PUT")

    let delete = DefaultEndpoint.deleteEndpoint.makeRequest(host: defaultHost)
    XCTAssertEqual(delete.httpMethod, "DELETE")
  }


  func testQueryParams() {
    let subject = ParamsEndpoint.withQuery(name: "foo", age: 42).makeRequest(host: defaultHost)
    XCTAssertEqual(subject.url!.absoluteString, "http://example.com/params?name=foo&age=42")
  }

  
  func  testDataBody() {
    var subject = DataEndpoint.postData.makeRequest(host: defaultHost)
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "post")
    
    subject = DataEndpoint.putData.makeRequest(host: defaultHost)
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "put")
  }
  
  
  func testFormParams() {
    var subject: URLRequest
    subject = ParamsEndpoint.postForm(name: "foo", age: 42).makeRequest(host: defaultHost)
    XCTAssertEqual(subject.url!.absoluteString, "http://example.com/params")
    XCTAssertEqual(subject.httpMethod, "POST")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "name=foo&age=42")
    
    subject = ParamsEndpoint.putForm(name: "bar", age: 64).makeRequest(host: defaultHost)
    XCTAssertEqual(subject.url!.absoluteString, "http://example.com/params")
    XCTAssertEqual(subject.httpMethod, "PUT")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "name=bar&age=64")
  }
  
  
  func testJSONParams() {
    var subject: URLRequest
    subject = JSONEndpoint.postJSON(name: "foo", age: 42).makeRequest(host: defaultHost)
    XCTAssertEqual(subject.url!.absoluteString, "http://example.com/json")
    XCTAssertEqual(subject.httpMethod, "POST")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/json")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "{\"name\":\"foo\",\"age\":42}")
    
    subject = JSONEndpoint.putJSON(name: "bar", age: 64).makeRequest(host: defaultHost)
    XCTAssertEqual(subject.url!.absoluteString, "http://example.com/json")
    XCTAssertEqual(subject.httpMethod, "PUT")
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "application/json")
    XCTAssertEqual(String(data: subject.httpBody!, encoding: .utf8), "{\"name\":\"bar\",\"age\":64}")
  }
  
  
  func testCustomJSONContentType() {
    var subject = JSONEndpoint.postCustomContent.makeRequest(host: defaultHost)
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "foo/bar")
    
    subject = JSONEndpoint.putCustomContent.makeRequest(host: defaultHost)
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "baz/quux")
  }

  
  func testCustomParamsContentType() {
    var subject = ParamsEndpoint.postCustomContent.makeRequest(host: defaultHost)
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "foo/bar")
    
    subject = ParamsEndpoint.putCustomContent.makeRequest(host: defaultHost)
    XCTAssertEqual(subject.value(forHTTPHeaderField: "Content-Type"), "baz/quux")
  }

  
  func testHostWithPort() {
    let host = Host(url: URL(string: "http://localhost:10175")!)
    let subject = DefaultEndpoint.getEndpoint.makeRequest(host: host)
    XCTAssertEqual(subject.url!.absoluteString, "http://localhost:10175/")
  }
}

import XCTest
import SessionArtist
import Perfidy



private enum PerfidyEndpoint: Endpoint {
  static let scheme = "http"
  static let host = "localhost"
  static let port = 10175

  case getEndpoint, postEndpoint, putEndpoint, deleteEndpoint, withHeader
  case withQuery(name: String, age: Int), withForm(name: String, age: Int), withJSON(name: String, age: Int)
  
  var request: URLRequest {
    switch self {
    case .getEndpoint:
      return get("/get")
    case .postEndpoint:
      return post("/post", params: [])
    case .putEndpoint:
      return put("/put", params: [])
    case .deleteEndpoint:
      return delete("/delete")
    case let .withQuery(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return get("/query", params: params)
    case let .withForm(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return post("/form", params: params)
    case let .withJSON(name, age):
      return try! post("/json", json: ["name": name, "age": age])
    case .withHeader:
      return get("/header", headers: ["foo": "bar", "Content-Type": "video/3gpp"])
    }
    
  }
}


private enum BogusEndpoint: Endpoint {
  static let host = "localhost"
  static let port = 11111
  
  case nowhere
  
  var request: URLRequest {
    return get("/")
  }
}



private enum API {
  static let perfidy = APISession<PerfidyEndpoint>()
  static let bogus = APISession<BogusEndpoint>()
}



class APISessionTests: XCTestCase {
  func testVerbs() {
    let shouldGet = expectation(description: "GET request")
    let shouldPost = expectation(description: "POST request")
    let shouldPut = expectation(description: "PUT request")
    let shouldDelete = expectation(description: "DELETE request")

    FakeServer.runWith { server in
      server.add(["GET /get", "POST /post", "PUT /put", "DELETE /delete"])
      API.perfidy.dataTask(for: .getEndpoint) {
        if case .response(200, _) = $0 {
          shouldGet.fulfill()
        }
      }
      API.perfidy.dataTask(for: .postEndpoint) {
        if case .response(200, _) = $0 {
          shouldPost.fulfill()
        }
      }
      API.perfidy.dataTask(for: .putEndpoint) {
        if case .response(200, _) = $0 {
          shouldPut.fulfill()
        }
      }
      API.perfidy.dataTask(for: .deleteEndpoint) {
        if case .response(200, _) = $0 {
          shouldDelete.fulfill()
        }
      }
      waitForExpectations(timeout: 1.0, handler: nil)
    }
  }
  
  
  func testDataResponse() {
    let shouldGetData = expectation(description: "get data back in response")
    let shouldFail = expectation(description: "fail")
    
    FakeServer.runWith { server in
      server.add("/get", response: "foo")
      API.perfidy.dataTask(for: .getEndpoint) { res in
        if case .response(200, let d) = res {
          XCTAssertEqual(String(data: d, encoding: .utf8), "foo")
          shouldGetData.fulfill()
        }
      }
      
      API.bogus.dataTask(for: .nowhere) { res in
        if case .failure(let e) = res {
          XCTAssertEqual((e as NSError).domain, NSURLErrorDomain)
          XCTAssertEqual((e as NSError).code, -1004)
          shouldFail.fulfill()
        }
      }
      
      waitForExpectations(timeout: 1.0, handler: nil)
    }
  }
  
  
  func testJSONResponse() {
    let shouldGetJSON = expectation(description: "get back response with JSON")
    let shouldFailParsing = expectation(description: "fail to parse invalid JSON")
    let shouldFailConnection = expectation(description: "fail to connect")
    
    FakeServer.runWith { server in
      server.add("/get", response: ["foo": "bar"])
      server.add("POST /post", response: "foobar")
      API.perfidy.jsonTask(for: .getEndpoint) { res in
        if case .response(200, let j) = res {
          XCTAssertEqual(j as! [String: String], ["foo": "bar"])
          shouldGetJSON.fulfill()
        }
      }
      
      API.perfidy.jsonTask(for: .postEndpoint) { res in
        if case .failure(ResponseError.invalidJSONObject) = res {
          shouldFailParsing.fulfill()
        }
      }
    
      API.bogus.jsonTask(for: .nowhere) { res in
        if case .failure(let e) = res {
          XCTAssertEqual((e as NSError).domain, NSURLErrorDomain)
          XCTAssertEqual((e as NSError).code, -1004)
          shouldFailConnection.fulfill()
        }
      }
      
      waitForExpectations(timeout: 1.0, handler: nil)
    }
  }
  
  
  func testRequests() {
    let shouldReceive = expectation(description: "receive request with json")
    let shouldRespond = expectation(description: "respond with 200")
    FakeServer.runWith { server in
      server.add("/header", response: 200) { req in
        XCTAssertEqual(req.value(forHTTPHeaderField: "foo"), "bar")
        XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), "video/3gpp")
        shouldReceive.fulfill()
      }
      
      API.perfidy.dataTask(for: .withHeader) { _ in
        shouldRespond.fulfill()
      }
      
      waitForExpectations(timeout: 1.0, handler: nil)
    }
  }
}

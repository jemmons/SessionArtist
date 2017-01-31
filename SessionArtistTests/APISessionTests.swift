import XCTest
import SessionArtist
import Perfidy



private enum MyEndpoint: Endpoint {
  case getEndpoint, postEndpoint, putEndpoint, deleteEndpoint, withHeader
  case withQuery(name: String, age: Int), withForm(name: String, age: Int), withJSON(name: String, age: Int)
  
  func makeRequest(host: Host) -> URLRequest {
    switch self {
    case .getEndpoint:
      return host.get("/get")
    case .postEndpoint:
      return host.post("/post", params: [])
    case .putEndpoint:
      return host.put("/put", params: [])
    case .deleteEndpoint:
      return host.delete("/delete")
    case let .withQuery(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return host.get("/query", params: params)
    case let .withForm(name, age):
      let params = [
        URLQueryItem(name: "name", value: name),
        URLQueryItem(name: "age", value: String(age))
      ]
      return host.post("/form", params: params)
    case let .withJSON(name, age):
      return try! host.post("/json", json: ["name": name, "age": age])
    case .withHeader:
      return host.get("/header", headers: ["foo": "bar", "Content-Type": "video/3gpp"])
    }
  }
}



private enum API {
  private static let perfidyURL = URL(string: "http://localhost:10175")!
  static let perfidy = APISession<MyEndpoint>(host: perfidyURL)
  static let bogus = APISession<MyEndpoint>(host: "http://localhost:11111")!
  static let headers = APISession<MyEndpoint>(host: perfidyURL, headers: ["Content-Type": "x-application/bogus"])
  static let timeouts = APISession<MyEndpoint>(host: perfidyURL, timeout: 0.1)
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
      
      API.bogus.dataTask(for: .getEndpoint) { res in
        if case .failure(let e) = res {
          XCTAssertEqual((e as NSError).domain, NSURLErrorDomain)
          XCTAssertEqual((e as NSError).code, -1004)
          shouldFail.fulfill()
        }
      }
      
      waitForExpectations(timeout: 1.0, handler: nil)
    }
  }
  
  
  func testJSONObjectResponse() {
    let shouldGetJSON = expectation(description: "get back response with JSON")
    let shouldFailParsing = expectation(description: "fail to parse invalid JSON")
    let shouldFailConnection = expectation(description: "fail to connect")
    
    FakeServer.runWith { server in
      server.add("/get", response: ["foo": "bar"])
      server.add("POST /post", response: "foobar")
      API.perfidy.jsonObjectTask(for: .getEndpoint) { res in
        if case .response(200, let j) = res {
          XCTAssertEqual(j as! [String: String], ["foo": "bar"])
          shouldGetJSON.fulfill()
        }
      }
      
      API.perfidy.jsonObjectTask(for: .postEndpoint) { res in
        if case .failure = res {
          shouldFailParsing.fulfill()
        }
      }
    
      API.bogus.jsonObjectTask(for: .getEndpoint) { res in
        if case .failure(let e) = res {
          XCTAssertEqual((e as NSError).domain, NSURLErrorDomain)
          XCTAssertEqual((e as NSError).code, -1004)
          shouldFailConnection.fulfill()
        }
      }
      
      waitForExpectations(timeout: 1.0, handler: nil)
    }
  }
  
  
  func testJSONArrayResponse() {
    let shouldGetJSON = expectation(description: "gets response with JSON Array")
    let shouldFailParsing = expectation(description: "fails to parse invalid JSON")
    let shouldFailConnection = expectation(description: "fail to connect")
    
    FakeServer.runWith { server in
      server.add("/get", response: try! Response(jsonArray: ["foo", "bar"]))
      server.add("POST /post", response: "foobar")
      API.perfidy.jsonArrayTask(for: .getEndpoint) { res in
        if case .response(200, let j) = res {
          XCTAssertEqual(j as! [String], ["foo", "bar"])
          shouldGetJSON.fulfill()
        }
      }
      
      API.perfidy.jsonArrayTask(for: .postEndpoint) { res in
        if case .failure = res {
          shouldFailParsing.fulfill()
        }
      }
      
      API.bogus.jsonArrayTask(for: .getEndpoint) { res in
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
  
  
  func testHeaders() {
    let shouldReceive = expectation(description: "receives request with header")
    let shouldRespond = expectation(description: "responds")
    
    FakeServer.runWith { server in
      server.add("/get", response: 200) { req in
        XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), "x-application/bogus")
        shouldReceive.fulfill()
      }
      
      API.headers.dataTask(for: .getEndpoint) { _ in
        shouldRespond.fulfill()
      }
      
      waitForExpectations(timeout: 1.0, handler: nil)
    }
  }
  
  
  func testTimeout(){
    let shouldTimeOut = expectation(description: "times out")
    FakeServer.runWith { server in
      server.add("/get", response: 666)
      
      API.timeouts.dataTask(for: .getEndpoint) { res in
        if
          case .failure(let error as NSError) = res,
          error.code == -1001,
          error.domain == NSURLErrorDomain {
          shouldTimeOut.fulfill()
        }
      }
      
      waitForExpectations(timeout: 0.5, handler: nil)
    }
  }
  
}

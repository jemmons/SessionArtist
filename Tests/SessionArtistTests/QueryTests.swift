import XCTest
import SessionArtist
import Perfidy



class QueryTests: XCTestCase {
  struct Person: Decodable {
    let firstName: String
    let lastName: String
    let age: Int
  }

  
  let fakeHost = Host(baseURL: FakeServer
    .defaultURL
    .appendingPathComponent("api")
    .appendingPathComponent("graphql"))
  
  
  func testQueryURL() {
    let expectedRequest = expectation(description: "Waiting for request with proper method and path.")
    let expectedResponse = expectation(description: "Waiting for response.")
    
    // Query uses the host URL and path rather than providing its own.
    FakeServer.runWith { server in
      server.add("POST /api/graphql") { _ in
        expectedRequest.fulfill()
      }
      
      fakeHost.query("foo") { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedRequest, expectedResponse], timeout: 10)
    }
  }
  
  
  func testRequest() {
    let expectedRequest = expectation(description: "Waiting for request with proper header and body.")
    let expectedResponse = expectation(description: "Waiting for response.")
    
    FakeServer.runWith { server in
      server.add("POST /api/graphql") { req in
        XCTAssertEqual(req.value(forHTTPHeaderField: HTTPHeaderField.contentType.description), "application/x-www-form-urlencoded")
        XCTAssertEqual(String(data: req.httpBody!, encoding: .utf8), "query=query%7Bviewer%7Bname%7D%7D")
        expectedRequest.fulfill()
      }
      
      fakeHost.query("query{viewer{name}}") { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedRequest, expectedResponse], timeout: 10)
    }
  }
  
  
  func testNon200() {
    let expectedDataResponse = expectation(description: "Waiting for error in data response.")
    let expectedModelResponse = expectation(description: "Waiting for error in model response.")

    FakeServer.runWith { server in
      server.add("POST /api/graphql", response: 500)
      
      fakeHost.query("foo") { res in
        switch res {
        case .success((.internalServerError, _)):
          expectedDataResponse.fulfill()
        default:
          XCTFail()
        }
      }
            
      fakeHost.query("foo", model: Person.self) { res in
        switch res {
        case .failure(let e):
          XCTAssertEqual(e.localizedDescription, "Expected “200: no error” but got “500: internal server error”.")
          expectedModelResponse.fulfill()
        default:
          XCTFail()
        }
      }
      
      wait(for: [expectedDataResponse, expectedModelResponse], timeout: 10)
    }
  }
  
  
  func testDataResponse() {
    let expectedResponse = expectation(description: "Waiting for response body.")
    
    FakeServer.runWith { server in
      server.add("POST /api/graphql", response: "hello")
      
      fakeHost.query("foo") { res in
        switch res {
        case .success((.ok, let d)):
          XCTAssertEqual(String(data: d, encoding: .utf8), "hello")
          expectedResponse.fulfill()
        default:
          XCTFail()
        }
      }
      
      wait(for: [expectedResponse], timeout: 10)
    }
  }
  
  
  func testModelDecoding() {
    let expectedResponse = expectation(description: "Waiting for decoded model")
    
    FakeServer.runWith { server in
      server.add("POST /api/graphql", response: ["firstName": "Josh", "lastName": "Emmons", "age": 43])
      
      fakeHost.query("foo", model: Person.self) { res in
        switch res {
        case .success(let p):
          XCTAssertEqual(p.firstName, "Josh")
          XCTAssertEqual(p.lastName, "Emmons")
          XCTAssertEqual(p.age, 43)
          expectedResponse.fulfill()
        
        default:
          XCTFail()
        }
      }
      
      wait(for: [expectedResponse], timeout: 10)
    }
  }
}

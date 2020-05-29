import Foundation
import XCTest
import SessionArtist
import Perfidy



private var dateFormatter: DateFormatter = {
  let f = DateFormatter()
  f.dateStyle = .short
  return f
}()



class EndpointConvertibleTests: XCTestCase {
  let fakeHost = Host(baseURL: FakeServer.defaultURL)
  
  
  enum MyAPI: EndpointConvertible {
    case userIndex
    case createUser(name: String)
    case updateUserBirthday(id: String, birthday: Date)
    case deleteUser(id: String)
    
    var endpoint: Endpoint {
      switch self {
      case .userIndex:
        return Endpoint(method: .get, path: "/user")
      
      case let .createUser(name: n):
        let json = try! ValidJSONObject(["name": n])
        return Endpoint(method: .post, path: "/user", params: .json(json))
      
      case let .updateUserBirthday(id: id, birthday: d):
        let date = dateFormatter.string(from: d)
        let json = try! ValidJSONObject(["birthday": date])
        return Endpoint(method: .put, path: "/user/" + id, params: .json(json))

      case let .deleteUser(id):
        return Endpoint(method: .delete, path: "/user/" + id)
      }
    }
  }
  
  
  func testIndex() {
    let expectedRequest = expectation(description: "Waiting for request.")
    let expectedResponse = expectation(description: "Waiting for response.")
    
    FakeServer.runWith { server in
      server.add("GET /user") { req in
        expectedRequest.fulfill()
      }
      
      fakeHost.request(MyAPI.userIndex).data{ res in
        if case .success = res {
          expectedResponse.fulfill()
        }
      }
      
      wait(for: [expectedRequest, expectedResponse], timeout: 1)
    }
  }
  
  
  func testCreation() {
    let expectedRequest = expectation(description: "Waiting for request.")
    let expectedResponse = expectation(description: "Waiting for response.")
    
    FakeServer.runWith { server in
      server.add("POST /user") { req in
        XCTAssertEqual(req.httpBody, "{\"name\":\"Josh\"}".data(using: .utf8))
        expectedRequest.fulfill()
      }
      
      fakeHost.request(MyAPI.createUser(name: "Josh")).data{ res in
        if case .success = res {
          expectedResponse.fulfill()
        }
      }
      
      wait(for: [expectedRequest, expectedResponse], timeout: 1)
    }
  }


  func testUpdate() {
    let expectedRequest = expectation(description: "Waiting for request.")
    let expectedResponse = expectation(description: "Waiting for response.")
    
    FakeServer.runWith { server in
      server.add("PUT /user/123") { req in
        XCTAssertEqual(String(data: req.httpBody!, encoding: .utf8), "{\"birthday\":\"1\\/2\\/99\"}")
        expectedRequest.fulfill()
      }
      
      let date = DateComponents(calendar: Calendar(identifier: .iso8601), year: 1999, month: 1, day: 2).date!
      fakeHost.request(MyAPI.updateUserBirthday(id: "123", birthday: date)).data { res in
        if case .success = res {
          expectedResponse.fulfill()
        }
      }
      
      wait(for: [expectedRequest, expectedResponse], timeout: 1)
    }
  }

  
  func testDelete() {
    let expectedRequest = expectation(description: "Waiting for request.")
    let expectedResponse = expectation(description: "Waiting for response.")
    
    FakeServer.runWith { server in
      server.add("DELETE /user/123") { req in
        expectedRequest.fulfill()
      }
      
      fakeHost.request(MyAPI.deleteUser(id: "123")).data { res in
        if case .success = res {
          expectedResponse.fulfill()
        }
      }
      
      wait(for: [expectedRequest, expectedResponse], timeout: 1)
    }
  }
}

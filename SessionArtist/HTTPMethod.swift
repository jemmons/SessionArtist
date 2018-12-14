import Foundation



/**
 Sum type encapsulating HTTP request methods.
 - Seealso: https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
 */
public enum HTTPMethod: CaseIterable {
  
  
  /// Idempotent request to retrieve whatever information is identified by a given URL. The REST equivalent of CRUD's "Read" operation.
  case get
 
  
  /// A request that the server updates the information identified by a given URL with the entity enclosed in the request. The REST equivalent of CRUD's "Update" operation.
  case post
  
  
  /// This is a hack that behaves just like `post` but, when interpreted by an `Endpoint`, sends params in the query string instead of the body. This can work around bugs such as clients that discard POST bodies before sending (looking at you, `WKWebView`s before iOS 11).
  case postQuery
  
  
  /// Idempotent request to store the enclosed entity be stored under the a given URL. The REST equivalent of CRUD's "Create" operation.
  case put
  
  
  /// Idempotent request for the server to remove the resource identified by a given URL. Performs the same role as its CRUD namesake.
  case delete
  
  
  /// Identical to a GET, but no body is returned in the response. Not frequently used in the context of REST.
  case head
  
  
  /// Used to invoke a remote, application-layer loop-back of the request message. Should not have side effects. Not frequently used in the context of REST.
  case trace
  
  
  /// Used in association with a proxy that can dynamically switch to being a tunnel (see: SSL). Not frequently used in the context of REST.
  case connect
  
  
  /// Represents a request for information about the available communication options. Should not have side effects. Not frequently used in the context of REST.
  case options
  
  
  /// Requests that a set of changes described in the enclosed entity be applied to the resource identified by a given URL. Not frequently used in the context of REST.
  case patch
  
  
  /// Constructs an `HTTPMethod`from a (case insensitive) string or returns `nil`. Note that variations on "POST" will allways return an `HTTPMethod.post` and never an `HTTPMethod.postQuery`.
  public init?(string: String) {
    guard let foundMethod = HTTPMethod.allCases.first(where: { string.compare($0.description, options: [.caseInsensitive], range: nil, locale: nil) == .orderedSame }) else {
      return nil
    }
    self = foundMethod
  }
}



extension HTTPMethod: CustomStringConvertible {
  public var description: String {
    switch self {
    case .head: return "HEAD"
    case .get: return "GET"
    case .post, .postQuery: return "POST"
    case .put: return "PUT"
    case .delete: return "DELETE"
    case .trace: return "TRACE"
    case .connect: return "CONNECT"
    case .options: return "OPTIONS"
    case .patch: return "PATCH"
    }
  }
}

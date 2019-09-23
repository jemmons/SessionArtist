import Foundation



/// A sum type representing valid HTTP status codes.
public enum HTTPStatusCode: Int {
  /// The range representing all possible informational status codes.
  public static let informationalRange = 100..<200
  
  
  /// The range representing all possible success status codes.
  public static let successRange = 200..<300
  
  
  /// The range representing all possible redirection status codes.
  public static let redirectionRange = 300..<400
  
  
  /// The range representing all possible client error status codes.
  public static let clientErrorRange = 400..<500
  
  
  /// The range representing all possible server error status codes.
  public static let serverErrorRange = 500..<600
  
  
  /// An "informational" status code
  case `continue` = 100,
  switchingProtocols,
  processing
  
  
  /// A "success" status code.
  case ok = 200,
  created,
  accepted,
  nonAuthoritativeInformation,
  noContent,
  resetContent,
  partialContent,
  multiStatus,
  alreadyReported
  /// A "success" status code.
  case imUsed = 226
  
  
  /// A "redirection" status code.
  case multipleChoices = 300,
  movedPermanently,
  found,
  seeOther,
  notModified,
  useProxy,
  switchProcy,
  temporaryRedirect,
  permanentRedirect
  
  
  /// A "client error" status code.
  case badRequest = 400,
  unauthorized,
  paymentRequired,
  forbidden,
  notFound,
  methodNotAllowed,
  notAcceptable,
  proxyAuthenticationRequired,
  requestTimeout,
  conflict,
  gone,
  lengthRequired,
  preconditionFailed,
  payloadTooLarge,
  uriTooLong,
  unsupportedMediaType,
  rangeNotSatisfiable,
  expectationFailed,
  imATeapot
  /// A "client error" status code.
  case misdirectedRequest = 421,
  unprocessableEntity,
  locked,
  failedDependency
  /// A "client error" status code.
  case upgradeRequired = 426
  /// A "client error" status code.
  case preconditionRequired = 428
  /// A "client error" status code.
  case tooManyRequests = 429
  /// A "client error" status code.
  case requestHeaderFieldsTooLarge = 431
  /// A "client error" status code.
  case unavailableForLegalReasons = 451
  
  
  /// A "server error" status code.
  case internalServerError = 500,
  notImplemented,
  badGateway,
  serviceUnavailable,
  gatewayTimeout,
  httpVersionNotSupported
}



extension HTTPStatusCode: CustomStringConvertible {
  /// A `String` representation of the receiver, localized to the current locale.
  public var description: String {
    let code = self.rawValue
    return code.description + ": " + HTTPURLResponse.localizedString(forStatusCode: code)
  }
}



public extension HTTPStatusCode {
  /// `true` if receiver represents a 1xx status code.
  var isInformational: Bool {
    switch self {
    case HTTPStatusCode.informationalRange:
      return true
    default:
      return false
    }
  }
  
  
  /// `true` if receiver represents a 2xx status code.
  var isSuccess: Bool {
    switch self {
    case HTTPStatusCode.successRange:
      return true
    default:
      return false
    }
  }
  
  
  /// `true` if receiver represents a 3xx status code.
  var isRedirection: Bool {
    switch self {
    case HTTPStatusCode.redirectionRange:
      return true
    default:
      return false
    }
  }
  
  
  /// `true` if receiver represents a 4xx status code.
  var isClientError: Bool {
    switch self {
    case HTTPStatusCode.clientErrorRange:
      return true
    default:
      return false
    }
  }
  
  
  /// `true` if receiver represents a 5xx status code.
  var isServerError: Bool {
    switch self {
    case HTTPStatusCode.serverErrorRange:
      return true
    default:
      return false
    }
  }
}



/**
 Allows the matching of an `HTTPStatusCode` with an `Int`. For example:
 
 ```
 switch myStatusCode {
 case 200:
 print("Success!")
 case 404:
 print("Not found!")
 default:
 //...
 }
 ```
 */
public func ~= (pattern: Int, value: HTTPStatusCode) -> Bool {
  return pattern == value.rawValue
}



/**
 Allows the matching of an `HTTPStatusCode` with a closed range. For example:
 
 ```
 switch myStatusCode {
 case 401...403:
 print("Needs Auth!")
 default:
 //...
 }
 ```
 */
public func ~= (pattern: CountableRange<Int>, value: HTTPStatusCode) -> Bool {
  return pattern.contains(value.rawValue)
}



/**
 Allows the matching of an `HTTPStatusCode` with a half-open range. This is particularly useful when used in conjunction with the ranges defined statically on `HTTPStatusCode`. For example:
 
 ```
 switch myStatusCode {
 case HTTPStatusCode.successRange:
 print("Success!")
 default:
 //...
 }
 ```
 */
public func ~= (pattern: CountableClosedRange<Int>, value: HTTPStatusCode) -> Bool {
  return pattern.contains(value.rawValue)
}

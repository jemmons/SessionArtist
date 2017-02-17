import Foundation



public enum HTTPHeaderField {
  case accept, acceptCharset, acceptEncoding, acceptLanguage, acceptVersion, authorization, cacheControl, connection, cookie, contentLength, contentMD5, contentType, date, host, origin, referer, userAgent
  case other(String)
}



extension HTTPHeaderField: CustomStringConvertible {
  public var description: String {
    switch self {
    case .accept: return "Accept"
    case .acceptCharset: return "Accept-Charset"
    case .acceptEncoding: return "Accept-Encoding"
    case .acceptLanguage: return "Accept-Language"
    case .acceptVersion: return "Accept-Version"
    case .authorization: return "Authorization"
    case .cacheControl: return "Cache-Control"
    case .connection: return "Connection"
    case .cookie: return "Cookie"
    case .contentLength: return "Content-Length"
    case .contentMD5: return "Content-MD5"
    case .contentType: return "Content-Type"
    case .date: return "Date"
    case .host: return "Host"
    case .origin: return "Origin"
    case .referer: return "Referer"
    case .userAgent: return "User-Agent"
    case .other(let s): return s
    }
  }
}



extension HTTPHeaderField: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .other(value)
  }
  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }
}



extension HTTPHeaderField: Equatable {
  public static func ==(lhs: HTTPHeaderField, rhs: HTTPHeaderField) -> Bool {
    return lhs.description == rhs.description
  }
}



extension HTTPHeaderField: Hashable {
  public var hashValue: Int {
    return description.hashValue
  }
}

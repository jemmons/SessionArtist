import Foundation



public enum HTTPHeaderField: Hashable {
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
  // swiftlint:disable:next cyclomatic_complexity
  public init(string: String) {
    switch string.lowercased() {
    case "accept": self = .accept
    case "accept-charset": self = .acceptCharset
    case "accept-encoding": self = .acceptEncoding
    case "accept-language": self = .acceptLanguage
    case "accept-version": self = .acceptVersion
    case "authorization": self = .authorization
    case "cache-control": self = .cacheControl
    case "connection": self = .connection
    case "cookie": self = .cookie
    case "content-length": self = .contentLength
    case "content-md5": self = .contentMD5
    case "content-type": self = .contentType
    case "date": self = .date
    case "host": self = .host
    case "origin": self = .origin
    case "referer": self = .referer
    case "user-agent": self = .userAgent
    default: self = .other(string)
    }
  }

  
  public init(stringLiteral value: String) {
    self.init(string: value)
  }
  
  
  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }
  
  
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }
}



extension HTTPHeaderField: Equatable {
  public static func == (lhs: HTTPHeaderField, rhs: HTTPHeaderField) -> Bool {
    return lhs.description.compare(rhs.description, options: [.caseInsensitive], range: nil, locale: Locale(identifier: "en_US_POSIX")) == .orderedSame
  }
}

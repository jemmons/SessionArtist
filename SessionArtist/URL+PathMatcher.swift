import Foundation



public extension URL {
  struct Host {
    public let host: String
    public init(_ host: String) {
      self.host = host
    }
  }
  
  
  struct Path {
    public let path: String
    public init(_ path: String) {
      self.path = path
    }
  }
  
  
  struct PathPrefix {
    public let pathPrefix: String
    public init(_ pathPrefix: String) {
      self.pathPrefix = pathPrefix
    }
  }
}



public func ~= (pattern: URL.Host, value: URL) -> Bool {
  return pattern.host == value.host
}



public func ~= (pattern: URL.Path, value: URL) -> Bool {
  return pattern.path == value.path
}



public func ~= (pattern: URL.PathPrefix, value: URL) -> Bool {
  return value.path.hasPrefix(pattern.pathPrefix)
}

import Foundation



public extension URL {
  struct Host {
    private let host: String
    
    
    public init(_ host: String) {
      self.host = host
    }
    
    
    public static func ~= (pattern: URL.Host, value: URL) -> Bool {
      return pattern.host == value.host
    }
  }
  
  
  struct Path {
    private let pathRepresentation: PathRepresentation


    public init(_ path: String) {
      pathRepresentation = .string(path)
    }
    
    
    public init(_ components: [String]) {
      pathRepresentation = .components(components)
    }


    public static func ~= (pattern: URL.Path, value: URL) -> Bool {
      switch pattern.pathRepresentation {
      case .string(let path):
        return path == value.path
      case .components(let components):
        return components == value.pathComponents
      }
    }
  }
  
  
  struct PathPrefix {
    private let pathPrefixRepresentation: PathRepresentation
    
    
    public init(_ pathPrefix: String) {
      pathPrefixRepresentation = .string(pathPrefix)
    }
    
    
    public init(_ components: [String]) {
      pathPrefixRepresentation = .components(components)
    }
   
    
    public static func ~= (pattern: URL.PathPrefix, value: URL) -> Bool {
      switch pattern.pathPrefixRepresentation {
      case .string(let path):
        return value.path.hasPrefix(path)
      case .components(let components):
        let valueComponentsPrefix = Array(value.pathComponents.prefix(components.count))
        return valueComponentsPrefix == components
      }
    }
  }
}


private enum PathRepresentation {
  case string(String)
  case components([String])
}

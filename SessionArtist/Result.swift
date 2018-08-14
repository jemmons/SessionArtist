import Foundation



public enum Result<T> {
  case success(T)
  case failure(Error)
  
  
  public init(_ value: T) {
    self = .success(value)
  }
  
  
  public init(_ error: Error) {
    self = .failure(error)
  }
}



public extension Result {
  func map<U>(transform: (T)->U) -> Result<U> {
    switch self {
    case .success(let t):
      return .success(transform(t))
    case .failure(let e):
      return .failure(e)
    }
  }
  
  
  func flatMap<U>(transform: (T) throws -> Result<U>) -> Result<U> {
    switch self {
    case .success(let t):
      do {
        return try transform(t)
      } catch {
        return .failure(error)
      }
    case .failure(let e):
      return .failure(e)
    }
  }

  
  func resolve() throws -> T {
    switch self {
    case .success(let t):
      return t
    case .failure(let e):
      throw e
    }
  }
}

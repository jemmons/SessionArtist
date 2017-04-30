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
  
  
  public func flatMap<U>(transform f: (T)->Result<U>) -> Result<U> {
    switch self {
    case .success(let t):
      return f(t)
    case .failure(let e):
      return Result<U>.failure(e)
    }
  }
}

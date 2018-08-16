import Foundation



/**
 An `Either` type wrapping either abitrary value of type `T` or an `Error`.
 */
public enum Result<T> {
  case success(T)
  case failure(Error)
  
  
  @available(*, deprecated, message: "Considered harmful. `Result(MyError)` will unexpectedly return a `Result<MyError>.success`." )
  public init(_ value: T) {
    self = .success(value)
  }
  
  
  @available(*, deprecated, message: "Considered harmful. `Result(MyError)` will unexpectedly return a `Result<MyError>.success`." )
  public init(_ error: Error) {
    self = .failure(error)
  }
}



public extension Result {
  var isSuccess: Bool {
    switch self {
    case .success:
      return true
    case .failure:
      return false
    }
  }
  
  
  var isFailure: Bool {
    return !isSuccess
  }
  
  
  /**
   If `self` is a `success`, unwraps the value and maps it to a new value via `transform` which is, itself, wrapped in a new `success`. If `self` is a `failure`, reutrns that failure directly without evaluating `transform`.
   * note: Implicit here is the idea that `transform` will always succeed. If it can fail, use `flatMap(transform:)` instead so that an error can be thrown or a `failure` returned.
   * seeAlso: `flatMap(transform:)`
   */
  func map<U>(transform: (T)->U) -> Result<U> {
    switch self {
    case .success(let t):
      return .success(transform(t))
    case .failure(let e):
      return .failure(e)
    }
  }
  
  
  /**
   If `self` is a `success`, unwraps the value and maps it to a new `success` *or* `failure` via `transform`. As a convenience, any errors thrown during `transform` will be mapped to a `failure`. If `self` is already a `failure`, reutrns that failure directly without evaluating `transform`.
   * seeAlso: `map(transform:)`, `asyncFlatMap(asyncTransform:completion:)`
   */
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

  
  /**
   If `self` is a `success`, unwraps the value and maps it to a new `success` *or* `failure` via `transform`, calling `completion` with the result. If `self` is already a `failure`, passes that failure directly `completion` without evaluating `transform`.
   * note: the transform function is, itself, asynchronous in the CPS-style.
   * seeAlso: `flatMap(transform:)`
   */
  func asyncFlatMap<U>(asyncTransform: (T, @escaping (Result<U>)->Void)->Void, completion: @escaping (Result<U>)->Void) {
    switch self {
    case .success(let t):
      asyncTransform(t) { u in
        completion(u)
      }
    case .failure(let e):
      completion(.failure(e))
    }
  }


  /// If `self` is a `success`, unwrap the value and return it. Otherwise, throw the `failure`'s error.
  func resolve() throws -> T {
    switch self {
    case .success(let t):
      return t
    case .failure(let e):
      throw e
    }
  }
  
  
  /// Compose two `Result` continuations. Unlike the generic `route(continuation:adaptor)`, this version `flatMap`s over results with `adaptor` so we don't have to deal with `failure` branches.
  static func flatRoute<U>(continuation: @escaping (Result<U>)->Void, adaptor: @escaping (T)->Result<U>) -> (Result<T>)->Void {
    return { t in
      continuation(t.flatMap(transform: adaptor))
    }
  }
  
  
  /**
   Compose two `Result` continuations via an adaptor that is, itself, asynchronous in the CPS-style. Necessary for adaptors that need to call async routines.
   * seeAlso: `flatRoute(continuation:adaptor:)
   */
  static func asyncFlatRoute<U>(continuation: @escaping (Result<U>)->Void, asyncAdaptor: @escaping (T, @escaping (Result<U>)->Void)->Void) -> (Result<T>)->Void {
    return { t in
      t.asyncFlatMap(asyncTransform: asyncAdaptor, completion: continuation)
    }
  }
}

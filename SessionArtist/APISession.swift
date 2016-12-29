import Foundation



public struct APISession<T: Endpoint>{
  private let session: URLSession
  
  
  public init(){
    session = SessionHelper.makeSession()
  }
  
  
  @discardableResult public func task(for endpoint: T, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
    let task = session.dataTask(with: endpoint.request, completionHandler: completion)
    task.resume()
    return task
  }
}



fileprivate enum SessionHelper {
  static func makeConfig() -> URLSessionConfiguration {
    return URLSessionConfiguration.default
  }
  static func makeSession() -> URLSession {
    return URLSession(configuration: makeConfig())
  }
}

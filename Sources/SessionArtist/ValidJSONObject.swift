import Foundation



public struct ValidJSONObject {
  public let value: JSONObject
  
  
  public init(_ jsonObject: JSONObject) throws {
    guard JSONSerialization.isValidJSONObject(jsonObject) else {
      throw Error.invalidJSONObject
    }
    value = jsonObject
  }
}

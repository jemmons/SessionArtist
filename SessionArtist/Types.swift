import Foundation



public enum FileError: Error {
  case fileNotFound
}



public enum GraphQLError: Error {
  case syntaxOrValidation(message: String)
  case execution(message: String)
  case unknown
}



public enum InitializationError: Error {
  case invalidURL
}

//
//  HTTPRequestExecutor.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 09.02.2021.
//

import Foundation

extension HTTPRequestExecutor {
  
  struct Configuration {
    var authorizationToken: String?
    let baseUrlPath: String
  }
  
}

typealias SessionToken = String

final class HTTPRequestExecutor: Service, RequestExecuting {
  
  var environment: ServiceLocator!
  
  private(set) var configuration: Configuration
    
  init(configuration: Configuration) {
    self.configuration = configuration
  }
  
  func updateSessionToken(_ token: SessionToken) {
    configuration.authorizationToken = token
  }
  
  private var tasks = Set<AnyDataTask>()

  @discardableResult
  func dataTask<T>(for request: Request<T>) -> DataTask<T>? {
    guard let urlString = [configuration.baseUrlPath,
                           request.path]
            .joined(separator: "/")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           var url = URL(string: urlString) else {
      return nil
    }
    
    var urlComponents = URLComponents(string: urlString)
    
    if request.method == .get || request.method == .delete {
      urlComponents?.queryItems = request.params.map { key, value in
        URLQueryItem(name: key, value: "\(value)")
      }
      url = urlComponents!.url!
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.httpMethodString
    urlRequest.allHTTPHeaderFields =  [
      "Content-Type": "application/json"
    ]
        
    if let token: String = configuration.authorizationToken {
      urlRequest.allHTTPHeaderFields = urlRequest.allHTTPHeaderFields?.merging(["Authorization": token],
                                                                               uniquingKeysWith: { $1 })
    }

    if request.method != .get && request.method != .delete {
      urlRequest.httpBody = encode(request.params, for: request.method)
    }
    
    let dataTask = DataTask<T>()
    dataTask.destructor = { [weak self, weak dataTask] in
      guard let self = self, let task = dataTask else { return }
      self.tasks.remove(task.asAnyTask())
    }
    
    let task = URLSession.shared.dataTask(with: urlRequest) { [weak dataTask] data, response, error in
      guard let response = response else { return }

//      let string = String(data: (data ?? .init()), encoding: .utf8) ?? ""
//      print(string)
      if let responseError = ResponseErrorParser.parseError(from: response, data: data ?? .init()) {
        if let data = data?.guaranteeData(),
           let serverError = ResponseErrorParser.parseError(from: data) {
          dataTask?.complete(with: .failure(serverError))
          return
        } else {
          dataTask?.complete(with: .failure(responseError))
          
          return
        }
      }

      if let data = data?.guaranteeData() {
        do {
          if let serverError = ResponseErrorParser.parseError(from: data) {
            dataTask?.complete(with: .failure(serverError))
            return
          }

          let result = try request.parser.parse(data: data)
          dataTask?.complete(with: .success(result))
        } catch let objectParserError {
          dataTask?.complete(with: .failure(objectParserError))
        }
      } else if let error = error {
        dataTask?.complete(with: .failure(error))
      }
    }

    dataTask.resumeAction = { task.resume() }
    dataTask.cancelAction = { task.cancel() }
    
    tasks.insert(dataTask.asAnyTask())
    
    return dataTask
  }
  
  @discardableResult
  func execute<T>(_ request: Request<T>) -> DataTask<T>? {
    let task = dataTask(for: request)
    task?.resumeAction?()
    
    return task
  }
  
}

private extension HTTPRequestExecutor {
  
  func encode(_ params: [String: Any?], for method: RequestMethod) -> Data? {
    switch method {
    case .get:
      return params.percentEscaped().data(using: .utf8)
    case .post, .put, .delete, .patch:
      return try? JSONSerialization.data(withJSONObject: params)
    }
  }
  
}

private extension RequestMethod {
  
  var httpMethodString: String {
    switch self {
    case .get: return "GET"
    case .post: return "POST"
    case .put: return "PUT"
    case .delete: return "DELETE"
    case .patch: return "PATCH"
    }
  }
  
}

private struct ResponseErrorParser {
  
  static func parseError(from response: URLResponse, data: Data) -> Error? {
    if let httpResponse = response as? HTTPURLResponse,
       !(200..<300).contains(httpResponse.statusCode) {
      return ResponseError(code: httpResponse.statusCode, message: extractErrorMessage(from: data))
    }
    return nil
  }
  
  
  static func extractErrorMessage(from data: Data) -> String? {
    guard let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers) as? JSON,
          let errorDictionary = json["error"] as? [String: Any]
    else {
      return nil
    }
    return errorDictionary["message"] as? String
  }
  
  static func parseError(from data: Data) -> Error? {
    guard let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers) as? JSON,
          let errorDictionary = json["error"] as? [String: Any],
          let codeString = errorDictionary["code"] as? String,
          let code = Int(codeString),
          let message = errorDictionary["message"] as? String
    else {
      return nil
    }
    
    return ServerError(code: code, message: message)
  }
  
}

struct ResponseError: Error, LocalizedError {
  
  let code: Int
  let message: String?
  
  var errorDescription: String? {
    [String(code), message].compactMap(id).joined(separator: " ")
  }
  
}

struct ServerError: Error, LocalizedError {
  
  let code: Int
  let message: String?
  
  var errorDescription: String? {
    [String(code), message].compactMap(id).joined(separator: " ")
  }
  
}

struct ConnectionError: Error {
  
  let code: Int
  
}

private extension Data {
  
  func guaranteeData() -> Data {
    if isEmpty {
      return try! JSONEncoder().encode([String: String]())
    } else {
      return self
    }
  }
  
}

private extension Dictionary {
  
  func percentEscaped() -> String {
    map { key, value in
      let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
      let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
      return escapedKey + "=" + escapedValue
    }
    .joined(separator: "&")
  }
  
}

private extension CharacterSet {
  
  static let urlQueryValueAllowed: CharacterSet = {
    let generalDelimitersToEncode = ":#[]@"
    let subDelimitersToEncode = "!$&'()*+,;="
    
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
    return allowed
  }()
  
}

func convertToDictionary(text: String) -> [String: Any]? {
  if let data = text.data(using: .utf8) {
    do {
      return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
      print(error.localizedDescription)
    }
  }
  return nil
}

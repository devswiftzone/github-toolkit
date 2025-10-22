//
//  Languages.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// List repository languages
  /// https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repository-languages
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  /// - Returns: [String:  Int]: [Language Name: Bytes of Code]
  public func languages(
    ownerID: String,
    repositoryName: String
  ) async throws -> [String: Int] {
    let path = "/repos/\(ownerID)/\(repositoryName)/languages"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, _) = try await execute( request)
    
    let languages = try decode([String: Int].self, from: data)
    
    return languages
  }
}

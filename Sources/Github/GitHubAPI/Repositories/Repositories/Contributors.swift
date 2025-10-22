//
//  Contributors.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// List repository contributors
  /// https://docs.github.com/ja/rest/repos/repos?apiVersion=2022-11-28#list-repository-contributors
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [User]
  public func contributors(
    ownerID: String,
    repositoryName: String,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [Contributor] {
    let path = "/repos/\(ownerID)/\(repositoryName)/contributors"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let queries: [String: String] = [
      "anon": "false", // Set False to not get anonymous contributors. anonymous contributors has invalid data model
      "per_page": String(perPage),
      "page": String(page),
    ]
    
    let request = HTTPRequest(method: method, url: endpoint, queries: queries, headers: headers)
    
    let (data, _) = try await execute( request)
    
    let contributors = try decode([Contributor].self, from: data)
    
    return contributors
  }
}

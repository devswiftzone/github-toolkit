//
//  Stargazers.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Stargazers
  /// https://docs.github.com/en/rest/activity/starring?apiVersion=2022-11-28#list-stargazers
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [User]
  public func stargazers(
    ownerID: String,
    repositoryName: String,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [User] {
    let path = "/repos/\(ownerID)/\(repositoryName)/stargazers"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    let queries: [String: String] = [
      "per_page": String(perPage),
      "page": String(page)
    ]
    
    let request = HTTPRequest(method: method, url: endpoint, queries: queries, headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let users = try decode([User].self, from: data)
    
    return users
  }
}

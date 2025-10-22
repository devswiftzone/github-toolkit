//
//  Repositories.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// List repositories for a user
  /// Lists public repositories for the specified user. Note: For GitHub AE, this endpoint will list internal repositories for the specified user.
  /// https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user
  /// - Parameters:
  ///   - ownerID: The handle for the GitHub user account.
  ///   - type: Limit results to repositories of the specified type.
  ///   - sort: The property to sort the results by.
  ///   - direction: The order to sort by. Default: asc when using full_name, otherwise desc.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [Repository]
  public func repositories(
    ownerID: String,
    type: RepositorySearchType = .owner,
    sort: RepositorySortType = .fullName,
    direction: OrderType = .asc,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [Repository] {
    let path = "/users/\(ownerID)/repos"
    let method: HTTPRequest.Method = .get
    let endpoint = baseURL.appending(path: path)
    
    let queries: [String: String] = [
      "type": type.rawValue,
      "sort": sort.rawValue,
      "direction": direction.rawValue,
      "per_page": String(perPage),
      "page": String(page),
    ]
    
    let request = HTTPRequest(
      method: method,
      url: endpoint,
      queries: queries,
      headers: headers
    )
    
    let (data, _) = try await execute( request)
    
    let response = try decode([Repository].self, from: data)
    return response
  }
}

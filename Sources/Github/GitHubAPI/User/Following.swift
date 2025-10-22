//
//  Following.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Lists the people who the specified user follows.
  /// https://docs.github.com/en/rest/users/followers?apiVersion=2022-11-28#list-the-people-a-user-follows
  /// - Parameters:
  ///   - userID: The handle for the GitHub user account.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  public func following(
    userID: String,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [User] {
    let path = "/users/\(userID)/following"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let queries: [String: String] = [
      "per_page": String(perPage) ,
      "page": String(page)
    ]
    
    let request = HTTPRequest(method: method, url: endpoint, queries: queries, headers: headers)
    let (data, _) = try await session.data(for: request)
    
    let users =  try decode([User].self, from: data)
    
    return users
  }
}

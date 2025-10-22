//
//  Followers.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Lists the people following the specified user.
  /// https://docs.github.com/en/rest/users/followers?apiVersion=2022-11-28#list-followers-of-a-user
  /// - Parameters:
  ///   - userID: The handle for the GitHub user account.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  public func followers(
    userID: String,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [User] {
    let path = "/users/\(userID)/followers"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let queries: [String: String] = [
      "per_page": String(perPage) ,
      "page": String(page)
    ]
    
    let request = HTTPRequest(method: method, url: endpoint, queries: queries, headers: headers)
    let (data, _) = try await execute( request)
    
    let users =  try decode([User].self, from: data)
    
    return users
  }
}

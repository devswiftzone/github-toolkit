//
//  Comments.swift
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
  /// List issue comments
  /// https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#list-issue-comments
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - issueNumber: The number that identifies the issue.
  ///   - since: Only show results that were last updated after the given time.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [Comment]
  public func comments(
    ownerID: String,
    repositoryName: String,
    issueNumber: Int,
    since: Date? = nil,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [Comment] {
    let path = "/repos/\(ownerID)/\(repositoryName)/issues/\(issueNumber)/comments"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    var queries: [String: String] = [
      "per_page": String(perPage),
      "page": String(page),
    ]
    
    since.map {
      let formatter = ISO8601DateFormatter()
      queries["since"] = formatter.string(from: $0)
    }
    
    let request = HTTPRequest(method: method, url: endpoint, queries: queries, headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let comments = try decode([Comment].self, from: data)
    
    return comments
  }
  
  /// List issue comments
  /// https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#list-issue-comments
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - pullNumber: The number that identifies the pull.
  ///   - since: Only show results that were last updated after the given time.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [Comment]
  public func comments(
    ownerID: String,
    repositoryName: String,
    pullNumber: Int,
    since: Date? = nil,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [Comment] {
    try await comments(
      ownerID: ownerID,
      repositoryName: repositoryName,
      issueNumber: pullNumber,
      since: since,
      perPage: perPage,
      page: page
    )
  }
}

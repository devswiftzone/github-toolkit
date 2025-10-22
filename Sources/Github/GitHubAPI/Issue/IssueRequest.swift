//
//  IssueRequest.swift
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
  /// Get an issue
  /// https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#get-an-issue
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - issueNumber: The number that identifies the issue.
  /// - Returns: Issue
  public func issue(
    ownerID: String,
    repositoryName: String,
    issueNumber: Int
  ) async throws -> Issue {
    let path = "/repos/\(ownerID)/\(repositoryName)/issues/\(issueNumber)"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let issue = try decode(Issue.self, from: data)
    
    return issue
  }
}

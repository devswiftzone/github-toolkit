//
//  Issues.swift
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
  /// List issues in a repository. Only open issues will be listed.
  /// https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#list-repository-issues
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - milestone: If an integer is passed, it should refer to a milestone by its number field. If the string * is passed, issues with any milestone are accepted. If the string none is passed, issues without milestones are returned.
  ///   - state: Indicates the state of the issues to return.
  ///   - assignee: Can be the name of a user. Pass in none for issues with no assigned user, and * for issues assigned to any user.
  ///   - creator: The user that created the issue.
  ///   - mentioned: A user that's mentioned in the issue.
  ///   - labels: A list of comma separated label names. Example: bug,ui,@high
  ///   - sort: What to sort results by.
  ///   - direction: The direction to sort the results by.
  ///   - since: Only show notifications updated after the given time.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [Issue]
  public func issues(
    ownerID: String,
    repositoryName: String,
    milestone: Int? = nil,
    state: IssueSearchState = .open,
    assignee: String? = nil,
    creator: String? = nil,
    mentioned: String? = nil,
    labels: [String] = [],
    sort: IssueSearchSortType = .created,
    direction: OrderType = .desc,
    since: Date? = nil,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [Issue] {
    let path = "/repos/\(ownerID)/\(repositoryName)/issues"
    let method: HTTPRequest.Method = .get
    let endpoint = baseURL.appending(path: path)
    
    var queries: [String: String] = [
      "state": state.rawValue,
      "sort": sort.rawValue,
      "direction": direction.rawValue,
      "per_page": String(perPage),
      "page": String(page),
    ]
    
    milestone.map { queries["milestone"] = String($0) }
    assignee.map { queries["assignee"] = String($0) }
    creator.map { queries["creator"] = String($0) }
    mentioned.map { queries["mentioned"] = String($0) }
    if !labels.isEmpty { queries["labels"] = labels.joined(separator: ",") }
    since.map {
      let formatter = ISO8601DateFormatter()
      queries["since"] = formatter.string(from: $0)
    }
    
    let request = HTTPRequest(
      method: method,
      url: endpoint,
      queries: queries,
      headers: headers
    )
    
    let (data, _) = try await session.data(for: request)
    
    let response = try decode([Issue].self, from: data)
    
    return response
  }
}

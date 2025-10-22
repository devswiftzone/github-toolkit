//
//  SearchRepositories.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Search repositories
  /// https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-repositories
  /// - Parameters:
  ///   - query: The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as the web interface for GitHub. To learn more about the format of the query, see Constructing a search query. See "Searching for repositories" for a detailed list of qualifiers.
  ///   - sort: Sorts the results of your query by number of stars, forks, or help-wanted-issues or how recently the items were updated. Default: best match
  ///   - order: Determines whether the first search result returned is the highest number of matches (desc) or lowest number of matches (asc). This parameter is ignored unless you provide sort.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: RepositoriesResponse
  public func searchRepositories(
    query: String,
    sort: RepositorySearchSortType? = nil,
    order: OrderType = .desc,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> RepositoriesResponse {
    let path = "/search/repositories"
    let method: HTTPRequest.Method = .get
    let endpoint = baseURL.appending(path: path)
    
    var queries: [String: String] = [
      "q": query,
      "order": order.rawValue,
      "per_page": String(perPage),
      "page": String(page)
    ]
    
    sort.map { queries["sort"] = $0.rawValue }
    
    let request = HTTPRequest(
      method: method,
      url: endpoint,
      queries: queries,
      headers: headers
    )
    
    let (data, _) = try await execute( request)
    
    let response = try decode(RepositoriesResponse.self, from: data)
    
    return response
  }
}

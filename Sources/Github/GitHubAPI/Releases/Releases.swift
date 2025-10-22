//
//  Releases.swift
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
  /// List releases
  /// https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#list-releases
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - perPage: The number of results per page (max 100).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [Release]
  public func releases(
    ownerID: String,
    repositoryName: String,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [Release] {
    let path = "/repos/\(ownerID)/\(repositoryName)/releases"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let queries: [String: String] = [
      "per_page": String(perPage),
      "page": String(page),
    ]
    
    let request = HTTPRequest(method: method, url: endpoint, queries: queries, headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let releases = try decode([Release].self, from: data)
    
    return releases
  }
}

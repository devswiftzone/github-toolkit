//
//  PullRequest.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Get a pull request
  /// https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#get-a-pull-request
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - pullNumber: The number that identifies the pull request.
  /// - Returns: Pull
  public func pull(
    ownerID: String,
    repositoryName: String,
    pullNumber: Int
  ) async throws -> Pull {
    let path = "/repos/\(ownerID)/\(repositoryName)/pulls/\(pullNumber)"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, _) = try await execute( request)
    
    let pull = try decode(Pull.self, from: data)
    
    return pull
  }
}

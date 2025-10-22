//
//  CreateFork.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Create a fork for the authenticated user.
  /// https://docs.github.com/en/rest/repos/forks?apiVersion=2022-11-28#create-a-fork
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - organization: Optional parameter to specify the organization name if forking into an organization.
  ///   - name: When forking from an existing repository, a new name for the fork.
  ///   - defaultBranchOnly: When forking from an existing repository, fork with only the default branch.
  /// - Returns: Repository
  public func createFork(
    ownerID: String,
    repositoryName: String,
    organization: String? = nil,
    name: String,
    defaultBranchOnly: Bool
  ) async throws -> Repository {
    let path = "/repos/\(ownerID)/\(repositoryName)/forks"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .post
    
    var body: [String: String] = [
      "name": name,
      "default_branch_only": defaultBranchOnly.description,
    ]
    
    organization.map {
      body["organization"] = $0
    }
    
    let bodyData = try JSONEncoder().encode(body)

    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)

    let (data, _) = try await execute(request, body: bodyData)
    
    let repository = try decode(Repository.self, from: data)
    
    return repository
  }
}

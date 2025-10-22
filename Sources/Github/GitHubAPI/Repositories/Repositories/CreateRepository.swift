//
//  CreateRepository.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Get a repository
  /// https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#get-a-repository
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  /// - Returns: Repository
  public func createRepository(
    repository: NewRepository
  ) async throws -> Repository {
    let path = "/user/repos"
    let method: HTTPRequest.Method = .post
    let endpoint = baseURL.appending(path: path)
    
    let request = HTTPRequest(
      method: method,
      url: endpoint,
      queries: [:],
      headers: headers
    )

    let body = try JSONEncoder.github.encode(repository)

    let (data, _) = try await execute(request, body: body)
    
    let repository = try decode(Repository.self, from: data)
    
    return repository
  }
}

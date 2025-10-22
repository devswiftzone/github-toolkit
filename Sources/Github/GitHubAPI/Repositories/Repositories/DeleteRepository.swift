//
//  DeleteRepository.swift
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
  /// Delete a repository
  /// https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#delete-a-repository
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  public func deleteRepository(
    ownerID: String,
    repositoryName: String
  ) async throws {
    let path = "/repos/\(ownerID)/\(repositoryName)"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .delete
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, httpResponse) = try await session.data(for: request)
            
    if httpResponse.status.code != 204 {
      throw RequestError.deleteRepository(data: data)
    }
  }
}

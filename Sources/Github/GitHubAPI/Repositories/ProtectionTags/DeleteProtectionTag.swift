//
//  DeleteProtectionTag.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Delete a tag protection state for a repository
  /// https://docs.github.com/en/rest/repos/tags?apiVersion=2022-11-28#delete-a-tag-protection-state-for-a-repository
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - tagID: The unique identifier of the tag protection.
  public func deleteProtectionTag(
    ownerID: String,
    repositoryName: String,
    tagID: ProtectionTag.ID
  ) async throws {
    let path = "/repos/\(ownerID)/\(repositoryName)/tags/protection/\(tagID)"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .delete
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, response) = try await session.data(for: request)
        
    if response.status.code != 204 {
      throw RequestError.deleteProtectionTag(data: data)
    }
  }
}

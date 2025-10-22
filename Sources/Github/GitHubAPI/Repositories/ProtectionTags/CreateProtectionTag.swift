//
//  CreateProtectionTag.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Create a tag protection state for a repository
  /// https://docs.github.com/en/rest/repos/tags?apiVersion=2022-11-28#create-a-tag-protection-state-for-a-repository
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - pattern: An optional glob pattern to match against when enforcing tag protection.
  /// - Returns: ProtectionTag
  public func createProtectionTag(
    ownerID: String,
    repositoryName: String,
    pattern: String
  ) async throws -> ProtectionTag {
    let path = "/repos/\(ownerID)/\(repositoryName)/tags/protection"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .post
    
    let body = try JSONEncoder.github.encode(["pattern": pattern])
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let bodyData = body
    
    let (data, _) = try await execute(request, body: bodyData)
    
    let tag = try decode(ProtectionTag.self, from: data)
    
    return tag
  }
}

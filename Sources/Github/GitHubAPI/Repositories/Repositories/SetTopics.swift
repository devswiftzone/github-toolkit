//
//  SetTopics.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Replace all repository topics
  /// https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#replace-all-repository-topics
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - topics: An array of topics to add to the repository. Pass one or more topics to replace the set of existing topics. Send an empty array ([]) to clear all topics from the repository. Note: Topic names cannot contain uppercase letters.
  /// - Returns: [String]
  public func setTopics(
    ownerID: String,
    repositoryName: String,
    topics: [String]
  ) async throws -> [String] {
    let path = "/repos/\(ownerID)/\(repositoryName)/topics"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .put

    let bodyData = TopicsResponse(names: topics)
    let encodedBody = try JSONEncoder.github.encode(bodyData)

    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)

    let (data, _) = try await execute(request, body: encodedBody)

    let response = try decode(TopicsResponse.self, from: data)

    return response.names
  }
}

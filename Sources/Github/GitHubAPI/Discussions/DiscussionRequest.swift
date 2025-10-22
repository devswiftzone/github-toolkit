//
//  DiscussionRequest.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  public func discussion(
    ownerID: String,
    repositoryName: String,
    discussionNumber: Int,
    itemFirst: Int
  ) async throws -> Discussion {
    try await self.discussion(
      ownerID: ownerID,
      repositoryName: repositoryName,
      discussionNumber: discussionNumber,
      itemFirst: itemFirst,
      itemLast: nil
    )
  }
  
  public func discussion(
    ownerID: String,
    repositoryName: String,
    discussionNumber: Int,
    itemLast: Int
  ) async throws -> Discussion {
    try await self.discussion(
      ownerID: ownerID,
      repositoryName: repositoryName,
      discussionNumber: discussionNumber,
      itemFirst: nil,
      itemLast: itemLast
    )
  }
  
  private func discussion(
    ownerID: String,
    repositoryName: String,
    discussionNumber: Int,
    itemFirst: Int? = nil,
    itemLast: Int? = nil
  ) async throws -> Discussion {
    let endpoint = baseURL.appending(path: "/graphql")
    let method: HTTPRequest.Method = .post
    
    let query = """
  query {
    repository(owner: "\(ownerID)", name: "\(repositoryName)") {
      discussion(number: \(discussionNumber)) \(discussionFields(first: itemFirst, last: itemLast))
    }
  }
  """
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let bodyData = try JSONEncoder().encode(["query": query])
    
    let (data, _) = try await execute(request, body: bodyData)
    let response = try decode(DiscussionResponse.self, from: data)
    
    return response.discussion
  }
}

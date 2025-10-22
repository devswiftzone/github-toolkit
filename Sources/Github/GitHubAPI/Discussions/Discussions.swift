//
//  Discussions.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  public func discussions(
    ownerID: String,
    repositoryName: String,
    first: Int,
    orderBy: DiscussionOrderField = .updatedAt,
    direction: OrderType = .desc
  ) async throws -> [Discussion] {
    try await self.discussions(
      ownerID: ownerID,
      repositoryName: repositoryName,
      first: first,
      last: nil,
      orderBy: orderBy,
      direction: direction
    )
  }
  
  public func discussions(
    ownerID: String,
    repositoryName: String,
    last: Int,
    orderBy: DiscussionOrderField = .updatedAt,
    direction: OrderType = .desc
  ) async throws -> [Discussion] {
    try await self.discussions(
      ownerID: ownerID,
      repositoryName: repositoryName,
      first: nil,
      last: last,
      orderBy: orderBy,
      direction: direction
    )
  }
  
  private func discussions(
    ownerID: String,
    repositoryName: String,
    first: Int? = nil,
    last: Int? = nil,
    orderBy: DiscussionOrderField = .updatedAt,
    direction: OrderType = .desc
  ) async throws -> [Discussion] {
    let endpoint = baseURL.appending(path: "/graphql")
    let method: HTTPRequest.Method = .post
    
    let query = """
  query {
    repository(owner: "\(ownerID)", name: "\(repositoryName)") {
      discussions(
        \(first.map { "first: \($0),"} ?? "")
        \(last.map { "last: \($0),"} ?? "")
        orderBy: {field: \(orderBy.rawValue), direction: \(direction.rawValue.uppercased())}
      ) {
        nodes \(discussionFields(first: first, last: last))
      }
    }
  }
  """
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    let body = try JSONEncoder().encode(["query": query])

    let (data, _) = try await execute(request, body: body)
    let response = try decode(DiscussionsResponse.self, from: data)
    
    return response.discussions
  }
  
  func discussionFields(first: Int?, last: Int?) -> String {
    """
  {
    id
    number
    url
    title
    updatedAt
    upvoteCount
    stateReason
    author \(userFields())
    createdAt
    activeLockReason
    authorAssociation
    body
    bodyHTML
    bodyText
    createdViaEmail
    databaseId
    editor \(userFields())
    includesCreatedEdit
    lastEditedAt
    locked
    viewerCanClose
    viewerCanDelete
    viewerCanReact
    viewerCanReopen
    viewerCanSubscribe
    viewerCanUpdate
    viewerCanUpvote
    viewerDidAuthor
    viewerHasUpvoted
    viewerSubscription
    poll \(pollFields(first: first, last: last))
    category \(categoryFields())
    comments(\(last.map { "last: \($0)"} ?? "") \(first.map { "first: \($0)"} ?? "")) {
      nodes \(commentFields())
    }
    labels(\(last.map { "last: \($0)"} ?? "") \(first.map { "first: \($0)"} ?? "")) {
      nodes \(labelFields())
    }
    reactions(\(last.map { "last: \($0)"} ?? "") \(first.map { "first: \($0)"} ?? "")) {
      nodes \(reactionFields())
    }
  }
  """
  }
  
  private func reactionFields() -> String {
    """
    {
      content
      createdAt
      databaseId
      user \(userFields())
    }
    """
  }
  
  private func labelFields() -> String {
    """
    {
      name
      color
      createdAt
      description
      isDefault
      resourcePath
      updatedAt
      url
    }
    """
  }
  private func categoryFields() -> String {
    """
  {
    createdAt
    description
    emoji
    emojiHTML
    isAnswerable
    name
    slug
    updatedAt
  }
  """
  }
  
  private func pollFields(first: Int?, last: Int? = nil) -> String {
    """
  {
    totalVoteCount
    question
    viewerCanVote
    viewerHasVoted
    options(\(last.map { "last: \($0)"} ?? "") \(first.map { "first: \($0)"} ?? "")) {
      nodes {
        option
        totalVoteCount
        viewerHasVoted
      }
    }
  }
  """
  }
  
  private func userFields() -> String {
    """
  {
    login
    avatarUrl
    resourcePath
    url
  }
  """
  }
  
  private func commentFields() -> String {
    """
  {
    id
    author \(userFields())
    body
    bodyHTML
    bodyText
    createdAt
    createdViaEmail
    editor \(userFields())
    authorAssociation
    includesCreatedEdit
    lastEditedAt
    publishedAt
    updatedAt
    viewerDidAuthor
  }
  """
  }
}

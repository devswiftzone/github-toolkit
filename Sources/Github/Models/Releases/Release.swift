//
//  Release.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation

public struct Release: Codable, Sendable, Hashable, Identifiable {
  public let id: Int
  public let nodeID: String
  public let name: String
  public let url: URL
  public let htmlURL: URL
  public let assetsURL: URL
  public let uploadURL: URL
  public let tarballURL: URL
  public let zipballURL: URL
  public let tagName: String
  public let targetCommitish: String
  public let body: String?
  public let draft: Bool
  public let prerelease: Bool
  public let createdAt: Date
  public let publishedAt: Date
  public let author: User
  public let assets: [Asset]
  public let bodyHTML: String?
  public let bodyText: String?
  public let mentionsCount: Int?
  public let discussionURL: URL?
  public let reactions: Reaction?
  
  public init(
    id: Int,
    nodeID: String,
    name: String,
    url: URL,
    htmlURL: URL,
    assetsURL: URL,
    uploadURL: URL,
    tarballURL: URL,
    zipballURL: URL,
    tagName: String,
    targetCommitish: String,
    body: String,
    draft: Bool,
    prerelease: Bool,
    createdAt: Date,
    publishedAt: Date,
    author: User,
    assets: [Asset],
    bodyHTML: String?,
    bodyText: String?,
    mentionsCount: Int?,
    discussionURL: URL?,
    reactions: Reaction?
  ) {
    self.id = id
    self.nodeID = nodeID
    self.name = name
    self.url = url
    self.htmlURL = htmlURL
    self.assetsURL = assetsURL
    self.uploadURL = uploadURL
    self.tarballURL = tarballURL
    self.zipballURL = zipballURL
    self.tagName = tagName
    self.targetCommitish = targetCommitish
    self.body = body
    self.draft = draft
    self.prerelease = prerelease
    self.createdAt = createdAt
    self.publishedAt = publishedAt
    self.author = author
    self.assets = assets
    self.bodyHTML = bodyHTML
    self.bodyText = bodyText
    self.mentionsCount = mentionsCount
    self.discussionURL = discussionURL
    self.reactions = reactions
  }
  
  private enum CodingKeys: String, CodingKey {
    case id
    case nodeID = "node_id"
    case name
    case url
    case htmlURL = "html_url"
    case assetsURL = "assets_url"
    case uploadURL = "upload_url"
    case tarballURL = "tarball_url"
    case zipballURL = "zipball_url"
    case tagName = "tag_name"
    case targetCommitish = "target_commitish"
    case body
    case draft
    case prerelease
    case createdAt = "created_at"
    case publishedAt = "published_at"
    case author
    case assets
    case bodyHTML = "body_html"
    case bodyText = "body_text"
    case mentionsCount = "mentions_count"
    case discussionURL = "discussion_url"
    case reactions
  }
}

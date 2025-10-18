//
//  Asset.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation

public struct Asset: Codable, Sendable, Hashable, Identifiable {
  public let id: Int
  public let nodeID: String
  public let label: String?
  public let state: State
  public let name: String
  public let url: URL
  public let browserDownloadURL: URL
  public let contentType: ContentType
  public let size: Int
  public let downloadCount: Int
  public let createdAt: Date
  public let updatedAt: Date
  public let uploader: User
  
  public init(
    id: Int,
    nodeID: String,
    label: String?,
    state: State,
    name: String,
    url: URL,
    browserDownloadURL: URL,
    contentType: ContentType,
    size: Int,
    downloadCount: Int,
    createdAt: Date,
    updatedAt: Date,
    uploader: User
  ) {
    self.id = id
    self.nodeID = nodeID
    self.label = label
    self.state = state
    self.name = name
    self.url = url
    self.browserDownloadURL = browserDownloadURL
    self.contentType = contentType
    self.size = size
    self.downloadCount = downloadCount
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.uploader = uploader
  }
  
  private enum CodingKeys: String, CodingKey {
    case url
    case browserDownloadURL = "browser_download_url"
    case id
    case nodeID = "node_id"
    case name
    case label
    case state
    case contentType = "content_type"
    case size
    case downloadCount = "download_count"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case uploader
  }
}

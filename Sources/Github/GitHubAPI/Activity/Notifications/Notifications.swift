//
//  Notifications.swift
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
  /// List notifications for the authenticated user
  /// https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
  /// - Parameters:
  ///   - all: If true, show notifications marked as read.
  ///   - participating: If true, only shows notifications in which the user is directly participating or mentioned.
  ///   - since: Only show results that were last updated after the given time.
  ///   - before: Only show notifications updated before the given time.
  ///   - perPage: The number of results per page (max 50).
  ///   - page: Page number of the results to fetch.
  /// - Returns: [Notification]
  public func notifications(
    all: Bool = false,
    participating: Bool = false,
    since: Date? = nil,
    before: Date? = nil,
    perPage: Int = 30,
    page: Int = 1
  ) async throws -> [Notification] {
    let path = "/notifications"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    var queries: [String: String] = [
      "all": all.description,
      "participating": participating.description,
      "per_page": String(perPage),
      "page": String(page),
    ]
    
    let formatter = ISO8601DateFormatter()
    since.map {
      queries["since"] = formatter.string(from: $0)
    }
    before.map {
      queries["before"] = formatter.string(from: $0)
    }
    
    let request = HTTPRequest(method: method, url: endpoint, queries: queries, headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let notifications = try decode([Notification].self, from: data)
   
    return notifications
  }
}

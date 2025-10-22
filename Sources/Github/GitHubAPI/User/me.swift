//
//  me.swift
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
  /// Get the authenticated user
  /// - Returns: User
  public func me() async throws -> User {
    let path = "/user"
    let method: HTTPRequest.Method = .get
    let endpoint = baseURL.appending(path: path)
    
    let request = HTTPRequest(
      method: method,
      url: endpoint,
      queries: [:],
      headers: headers
    )
    
    let (data, _) = try await session.data(for: request)
    
    let user = try decode(User.self, from: data)
    return user
  }
}

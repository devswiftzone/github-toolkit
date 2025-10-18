//
//  GitHubAPI.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation

public struct GitHub: Sendable {
  public var baseURL = URL(string: "https://api.github.com")!
  public var authorizationType: AuthorizationType
  public var session: URLSession
  public let rateLimitHandler: RateLimitHandler

  public init(
    type authorizationType: AuthorizationType,
    session: URLSession = .shared,
    rateLimitOptions: RateLimitOptions = .default
  ) {
    self.authorizationType = authorizationType
    self.session = session
    self.rateLimitHandler = RateLimitHandler(options: rateLimitOptions)
  }

  public init(
    accessToken: String,
    session: URLSession = .shared,
    rateLimitOptions: RateLimitOptions = .default
  ) {
    self.authorizationType = .bearerToken(accessToken: accessToken)
    self.session = session
    self.rateLimitHandler = RateLimitHandler(options: rateLimitOptions)
  }

  public var headers: [String: String] {
    var headers: [String: String] = [
      "Accept": "application/vnd.github+json"
    ]
    if case .bearerToken(accessToken: let token) = authorizationType {
      headers["Authorization"] = "Bearer \(token)"
    }
    return headers
  }

  /**
   * Obtiene el rate limit actual.
   */
  public func getCurrentRateLimit() async -> RateLimit? {
    return await rateLimitHandler.getCurrentRateLimit()
  }

  /**
   * Verifica el rate limit antes de hacer una request.
   */
  public func checkRateLimit() async throws {
    try await rateLimitHandler.shouldProceed()
  }
}

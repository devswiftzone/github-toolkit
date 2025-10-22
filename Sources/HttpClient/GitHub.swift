//
//  GitHubAPI.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import AsyncHTTPClient
import HTTPTypes
import NIOCore
import NIOHTTP1

public struct GitHub: Sendable {
  public var baseURL = URL(string: "https://api.github.com")!
  public var authorizationType: AuthorizationType
  public let httpClient: HTTPClient
  public let rateLimitHandler: RateLimitHandler
  private let ownsClient: Bool

  public init(
    type authorizationType: AuthorizationType,
    httpClient: HTTPClient? = nil,
    rateLimitOptions: RateLimitOptions = .default
  ) {
    self.authorizationType = authorizationType
    if let httpClient = httpClient {
      self.httpClient = httpClient
      self.ownsClient = false
    } else {
      self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
      self.ownsClient = true
    }
    self.rateLimitHandler = RateLimitHandler(options: rateLimitOptions)
  }

  public init(
    accessToken: String,
    httpClient: HTTPClient? = nil,
    rateLimitOptions: RateLimitOptions = .default
  ) {
    self.authorizationType = .bearerToken(accessToken: accessToken)
    if let httpClient = httpClient {
      self.httpClient = httpClient
      self.ownsClient = false
    } else {
      self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
      self.ownsClient = true
    }
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

  /**
   * Cierra el cliente HTTP si fue creado internamente.
   */
  public func shutdown() async throws {
    if ownsClient {
      try await httpClient.shutdown()
    }
  }
}

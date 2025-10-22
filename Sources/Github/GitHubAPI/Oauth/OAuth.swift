//
//  OAuth.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes
import AsyncHTTPClient
import NIOCore

/// OAuth
/// https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#2-users-are-redirected-back-to-your-site-by-github
@available(macOS 13.0, *)
public struct OAuth: Sendable {
  public enum ResponseType: String, Sendable {
    case `default`
    case json = "application/json"
    case xml = "application/xml"
  }

  public var baseURL = URL(string: "https://github.com/login")!
  private let path = "/oauth/access_token"

  public var clientID: String
  public var clientSecret: String
  public var code: String
  public var redirectURL: URL?

  public init(
    clientID: String,
    clientSecret: String,
    code: String,
    redirectURL: URL? = nil,
    responseType: ResponseType = .default
  ) {
    self.clientID = clientID
    self.clientSecret = clientSecret
    self.code = code
    self.redirectURL = redirectURL
  }

  public func request(responseType: ResponseType = .default) -> HTTPRequest {
    let endpoint = baseURL.appending(path: path)

    var queries: [String: String] = [
      "client_id": clientID,
      "client_secret": clientSecret,
      "code": code
    ]

    redirectURL.map { queries["redirect_uri"] = $0.absoluteString }

    var urlComponents = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)!
    urlComponents.queryItems = queries.map { .init(name: $0.key, value: $0.value) }

    var headers: [String: String] = [:]
    if responseType != .default {
      headers["Accept"] = responseType.rawValue
    }

    return HTTPRequest(
      method: .post,
      url: endpoint,
      queries: queries,
      headers: headers
    )
  }

  public func authorize(httpClient: HTTPClient) async throws -> OAuthResponse {
    let request = self.request(responseType: .json)

    // Construir la URL completa
    let urlString = "\(request.scheme ?? "https")://\(request.authority ?? "github.com")\(request.path ?? "/")"

    // Construir la request de AsyncHTTPClient
    var ahcRequest = AsyncHTTPClient.HTTPClientRequest(url: urlString)
    ahcRequest.method = .POST

    // Agregar headers
    for field in request.headerFields {
      ahcRequest.headers.add(name: field.name.canonicalName, value: field.value)
    }

    // Ejecutar la request
    let response: AsyncHTTPClient.HTTPClientResponse

    do {
      response = try await httpClient.execute(ahcRequest, timeout: .seconds(30))
    } catch {
      throw GitHubError.request(request: request)
    }

    // Leer el body
    let body = try await response.body.collect(upTo: 10 * 1024 * 1024) // 10MB max
    let data = Data(buffer: body)

    do {
      let oauthResponse = try JSONDecoder.github.decode(OAuthResponse.self, from: data)
      return oauthResponse
    } catch {
      // Create a mock HTTPResponse for compatibility
      let mockResponse = HTTPResponse(status: HTTPResponse.Status(code: Int(response.status.code), reasonPhrase: response.status.reasonPhrase))
      throw GitHubError.decode(data: data, response: mockResponse)
    }
  }
}

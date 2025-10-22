//
//  HTTPRequest++.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HTTPTypes
import AsyncHTTPClient
import NIOCore
import NIOHTTP1

public extension HTTPRequest {
  init(
    method: HTTPRequest.Method,
    url: URL,
    queries: [String: String],
    headers: [String: String]
  ) {
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    components.queryItems = queries.map { .init(name: $0.key, value: $0.value) }

    var headerFields: HTTPFields = .init()
    for (key, value) in headers {
      if let fieldName = HTTPField.Name(key) {
        headerFields[fieldName] = value
      }
    }

    self.init(method: method, scheme: components.scheme, authority: components.host, path: components.path + (components.query.map { "?\($0)" } ?? ""), headerFields: headerFields)
  }
}

@available(macOS 13.0, *)
public extension GitHub {
  /**
   * Ejecuta una petición HTTP usando AsyncHTTPClient.
   *
   * - Parameter request: El HTTPRequest a ejecutar
   * - Parameter body: Datos opcionales del body HTTP
   * - Returns: Una tupla con los datos de respuesta y los headers HTTP
   */
  func execute(_ request: HTTPRequest, body: Data? = nil) async throws -> (Data, HTTPHeaders) {
    // Construir la URL completa
    let urlString = "\(request.scheme ?? "https")://\(request.authority ?? "api.github.com")\(request.path ?? "/")"

    // Construir la request de AsyncHTTPClient
    var ahcRequest = AsyncHTTPClient.HTTPClientRequest(url: urlString)
    ahcRequest.method = convertMethod(request.method)

    // Agregar headers
    for field in request.headerFields {
      ahcRequest.headers.add(name: field.name.canonicalName, value: field.value)
    }

    // Agregar body si existe
    if let body = body {
      ahcRequest.body = .bytes(ByteBuffer(data: body))
    }

    // Ejecutar la request
    let response = try await httpClient.execute(ahcRequest, timeout: .seconds(30))

    // Procesar rate limit headers
    await processRateLimitHeaders(from: response.headers)

    // Leer el body
    let responseBody = try await response.body.collect(upTo: 10 * 1024 * 1024) // 10MB max
    let data = Data(buffer: responseBody)

    // Verificar el status code
    guard response.status == .ok || response.status == .created || response.status == .noContent else {
      if response.status == .tooManyRequests {
        // Intentar manejar el rate limit
        let retryAfter = response.headers.first(name: "Retry-After")
        try await rateLimitHandler.handle429Response(retryAfter: retryAfter)
        // Reintentar la request
        return try await execute(request, body: body)
      }
      throw RequestError.httpError(statusCode: Int(response.status.code), data: data)
    }

    return (data, response.headers)
  }

  private func convertMethod(_ method: HTTPRequest.Method) -> HTTPMethod {
    switch method {
    case .get: return .GET
    case .post: return .POST
    case .put: return .PUT
    case .delete: return .DELETE
    case .patch: return .PATCH
    case .head: return .HEAD
    case .options: return .OPTIONS
    case .trace: return .TRACE
    case .connect: return .CONNECT
    default: return .GET
    }
  }

  private func processRateLimitHeaders(from headers: HTTPHeaders) async {
    let headersDict = headers.reduce(into: [String: String]()) { result, header in
      result[header.name] = header.value
    }
    await rateLimitHandler.update(from: headersDict)
  }
}

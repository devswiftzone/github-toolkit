//
//  GitHub+RateLimit.swift
//
//
//  Created by GitHub Toolkit
//

import Foundation
import AsyncHTTPClient
import HTTPTypes
import NIOCore

@available(macOS 13.0, *)
extension GitHub {
    /**
     * Obtiene el estado actual del rate limit consultando el endpoint /rate_limit.
     *
     * - Returns: Información completa del rate limit.
     */
    public func getRateLimitStatus() async throws -> RateLimitStatus {
        // Crear la petición HTTP
        let path = "/rate_limit"
        let endpoint = baseURL.appendingPathComponent(path)
        let method: HTTPRequest.Method = .get

        let request = HTTPRequest(
            method: method,
            url: endpoint,
            queries: [:],
            headers: headers
        )

        // Ejecutar la request
        let (data, _) = try await execute(request)

        // Decodificar la respuesta
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(RateLimitStatus.self, from: data)
    }
}

/**
 * Respuesta completa del endpoint /rate_limit de GitHub.
 */
public struct RateLimitStatus: Codable, Sendable {
    public let resources: RateLimitResources
    public let rate: RateLimitResource

    public struct RateLimitResources: Codable, Sendable {
        public let core: RateLimitResource
        public let search: RateLimitResource
        public let graphql: RateLimitResource
        public let integrationManifest: RateLimitResource?
        public let sourceImport: RateLimitResource?
        public let codeSearching: RateLimitResource?
        public let actionsRunnerRegistration: RateLimitResource?
        public let scim: RateLimitResource?
        public let dependencySnapshots: RateLimitResource?
        public let codeScanning: RateLimitResource?
    }

    public struct RateLimitResource: Codable, Sendable {
        public let limit: Int
        public let used: Int
        public let remaining: Int
        public let reset: Int

        public var resetDate: Date {
            return Date(timeIntervalSince1970: TimeInterval(reset))
        }
    }
}

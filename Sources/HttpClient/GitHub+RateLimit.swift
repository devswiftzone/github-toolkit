//
//  GitHub+RateLimit.swift
//
//
//  Created by GitHub Toolkit
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension GitHub {
    /**
     * Procesa una respuesta HTTP y actualiza el rate limit.
     *
     * - Parameter response: La respuesta HTTP.
     */
    public func processRateLimitHeaders(from response: HTTPURLResponse) async {
        // Convertir headers a diccionario [String: String]
        let headers = response.allHeaderFields.reduce(into: [String: String]()) { result, element in
            if let key = element.key as? String, let value = element.value as? String {
                result[key] = value
            }
        }

        await rateLimitHandler.update(from: headers)
    }

    /**
     * Maneja errores de rate limit (código 429).
     *
     * - Parameters:
     *   - response: La respuesta HTTP.
     *   - retry: Closure que se ejecutará después de esperar el tiempo necesario.
     * - Returns: El resultado del retry si se configuró autoRetry, o lanza un error.
     */
    public func handleRateLimitError(
        from response: HTTPURLResponse,
        retry: () async throws -> (Data, URLResponse)
    ) async throws -> (Data, URLResponse) {
        let headers = response.allHeaderFields.reduce(into: [String: String]()) { result, element in
            if let key = element.key as? String, let value = element.value as? String {
                result[key] = value
            }
        }

        let retryAfter = headers["Retry-After"] ?? headers["retry-after"]

        // Intentar manejar el error 429
        try await rateLimitHandler.handle429Response(retryAfter: retryAfter)

        // Si llegamos aquí, el handler está configurado para reintentar
        return try await retry()
    }

    /**
     * Obtiene el estado actual del rate limit consultando el endpoint /rate_limit.
     *
     * - Returns: Información completa del rate limit.
     */
    public func getRateLimitStatus() async throws -> RateLimitStatus {
        // Create endpoint URL using appendingPathComponent for compatibility
        let endpoint = baseURL.appendingPathComponent("rate_limit")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"

        // Agregar headers de autenticación
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Use async/await API
        let (data, response) = try await session.data(for: request)

        // Actualizar rate limit desde headers
        if let httpResponse = response as? HTTPURLResponse {
            await processRateLimitHeaders(from: httpResponse)
        }

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

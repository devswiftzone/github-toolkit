//
//  RateLimit.swift
//
//
//  Created by GitHub Toolkit
//

import Foundation

/**
 * Información sobre el rate limit de la API de GitHub.
 */
public struct RateLimit: Sendable {
    /// Número máximo de requests permitidos por hora
    public let limit: Int

    /// Número de requests restantes en la ventana actual
    public let remaining: Int

    /// Número de requests usados en la ventana actual
    public let used: Int

    /// Timestamp Unix cuando se reseteará el rate limit
    public let reset: Date

    /// Recurso al que aplica este rate limit (core, search, graphql, etc.)
    public let resource: String

    /**
     * Inicializa un RateLimit a partir de los headers de respuesta HTTP.
     *
     * - Parameter headers: Headers de la respuesta HTTP.
     * - Parameter resource: El recurso al que aplica (default: "core").
     */
    public init?(headers: [String: String], resource: String = "core") {
        // GitHub envía los headers con estos nombres
        guard let limitStr = headers["x-ratelimit-limit"] ?? headers["X-RateLimit-Limit"],
              let remainingStr = headers["x-ratelimit-remaining"] ?? headers["X-RateLimit-Remaining"],
              let usedStr = headers["x-ratelimit-used"] ?? headers["X-RateLimit-Used"],
              let resetStr = headers["x-ratelimit-reset"] ?? headers["X-RateLimit-Reset"],
              let limit = Int(limitStr),
              let remaining = Int(remainingStr),
              let used = Int(usedStr),
              let resetTimestamp = TimeInterval(resetStr) else {
            return nil
        }

        self.limit = limit
        self.remaining = remaining
        self.used = used
        self.reset = Date(timeIntervalSince1970: resetTimestamp)
        self.resource = headers["x-ratelimit-resource"] ?? headers["X-RateLimit-Resource"] ?? resource
    }

    /**
     * Verifica si se ha alcanzado el límite.
     */
    public var isExceeded: Bool {
        return remaining == 0
    }

    /**
     * Tiempo restante hasta el reset del rate limit.
     */
    public var timeUntilReset: TimeInterval {
        return reset.timeIntervalSinceNow
    }

    /**
     * Porcentaje de uso del rate limit (0-100).
     */
    public var usagePercentage: Double {
        guard limit > 0 else { return 0 }
        return (Double(used) / Double(limit)) * 100
    }
}

/**
 * Errores relacionados con rate limiting.
 */
public enum RateLimitError: Error, LocalizedError {
    case exceeded(rateLimit: RateLimit)
    case retryAfter(seconds: TimeInterval)

    public var errorDescription: String? {
        switch self {
        case .exceeded(let rateLimit):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
            return "Rate limit exceeded. Resets at \(formatter.string(from: rateLimit.reset)). Remaining: \(rateLimit.remaining)/\(rateLimit.limit)"
        case .retryAfter(let seconds):
            return "Rate limit exceeded. Retry after \(Int(seconds)) seconds"
        }
    }
}

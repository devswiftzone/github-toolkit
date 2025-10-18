//
//  RateLimitHandler.swift
//
//
//  Created by GitHub Toolkit
//

import Foundation

/**
 * Opciones de configuración para el manejo de rate limiting.
 */
public struct RateLimitOptions: Sendable {
    /// Si es true, automáticamente espera y reintenta cuando se alcanza el rate limit
    public let autoRetry: Bool

    /// Número máximo de reintentos automáticos
    public let maxRetries: Int

    /// Si es true, lanza un error cuando se alcanza el rate limit en lugar de esperar
    public let throwOnLimit: Bool

    /// Umbral de advertencia (0.0 - 1.0). Si se supera este porcentaje, se emite una advertencia
    public let warningThreshold: Double

    public init(
        autoRetry: Bool = false,
        maxRetries: Int = 3,
        throwOnLimit: Bool = true,
        warningThreshold: Double = 0.8
    ) {
        self.autoRetry = autoRetry
        self.maxRetries = maxRetries
        self.throwOnLimit = throwOnLimit
        self.warningThreshold = warningThreshold
    }

    public static let `default` = RateLimitOptions()
}

/**
 * Handler para gestionar el rate limiting de la API de GitHub.
 */
public actor RateLimitHandler {
    private var currentRateLimit: RateLimit?
    private let options: RateLimitOptions

    public init(options: RateLimitOptions = .default) {
        self.options = options
    }

    /**
     * Actualiza el rate limit actual a partir de los headers de respuesta.
     */
    public func update(from headers: [String: String]) {
        if let rateLimit = RateLimit(headers: headers) {
            self.currentRateLimit = rateLimit

            // Emitir advertencia si se supera el umbral
            if rateLimit.usagePercentage >= options.warningThreshold * 100 {
                print("⚠️ Rate limit warning: \(rateLimit.remaining)/\(rateLimit.limit) requests remaining (\(String(format: "%.1f", rateLimit.usagePercentage))% used)")
            }
        }
    }

    /**
     * Obtiene el rate limit actual.
     */
    public func getCurrentRateLimit() -> RateLimit? {
        return currentRateLimit
    }

    /**
     * Verifica si se debe proceder con una request o si se debe esperar/fallar.
     */
    public func shouldProceed() async throws {
        guard let rateLimit = currentRateLimit, rateLimit.isExceeded else {
            return
        }

        if options.throwOnLimit {
            throw RateLimitError.exceeded(rateLimit: rateLimit)
        }

        if options.autoRetry {
            let waitTime = max(0, rateLimit.timeUntilReset)
            if waitTime > 0 {
                print("⏳ Rate limit exceeded. Waiting \(Int(waitTime)) seconds until reset...")
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        } else {
            throw RateLimitError.exceeded(rateLimit: rateLimit)
        }
    }

    /**
     * Maneja una respuesta 429 (Too Many Requests).
     */
    public func handle429Response(retryAfter: String?) async throws {
        if let retryAfterStr = retryAfter, let seconds = TimeInterval(retryAfterStr) {
            if options.autoRetry {
                print("⏳ Rate limit exceeded (429). Waiting \(Int(seconds)) seconds...")
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            } else if options.throwOnLimit {
                throw RateLimitError.retryAfter(seconds: seconds)
            }
        } else if options.throwOnLimit {
            throw RateLimitError.retryAfter(seconds: 60) // Default 60 seconds
        }
    }
}

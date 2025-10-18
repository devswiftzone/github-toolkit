# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Summary API Completa**: Implementación completa del Summary API para crear resúmenes Markdown
  - `write()`: Escribe el buffer al archivo de summary
  - `clear()`: Limpia el buffer y el archivo
  - `getfilePath()`: Obtiene la ruta del archivo summary
  - 12 métodos de construcción: `addHeading()`, `addCodeBlock()`, `addList()`, `addTable()`, etc.
  - Soporte para method chaining
  - Manejo completo de errores con `SummaryError`
  - Validación de permisos de lectura/escritura

- **Sistema Completo de Rate Limiting**: Implementación robusta para manejar límites de la API de GitHub
  - `RateLimit`: Struct para información de rate limit
  - `RateLimitHandler`: Actor para manejo thread-safe
  - `RateLimitOptions`: Configuración personalizable (auto-retry, thresholds, etc.)
  - Extracción automática desde headers HTTP
  - Advertencias configurables
  - Auto-retry con sleep inteligente
  - Soporte para endpoint `/rate_limit`
  - Struct `RateLimitStatus` con información completa de todos los recursos API

- **Suite de Tests Básicos**: 19 tests comprehensivos
  - 5 tests de HttpClient (autenticación, inicialización)
  - 2 tests de Core (environment, GitHub Actions detection)
  - 10 tests de Summary (todos los métodos de construcción)
  - 2 tests de Models (User decoding, Repository visibility)

- **Documentación Completa**:
  - README expandido con 40+ ejemplos de código
  - Sección de Rate Limiting con ejemplos
  - Guía completa para crear GitHub Actions con Swift (GITHUB_ACTIONS_GUIDE.md)
  - 3 ejemplos completos de actions
  - Mejores prácticas y patrones recomendados
  - Ejemplo básico de action listo para usar

### Fixed
- **Errores Ortográficos Corregidos**:
  - `Acitivity/` → `Activity/`
  - `Foks/` → `Forks/`
  - `ProtentionTags/` → `ProtectionTags/`
  - `Realeases/` → `Releases/`

- **Visibilidad de APIs**:
  - Todos los métodos de Summary son ahora `public`
  - `SummaryError` es `public`
  - `SummaryWriteOptions` es `public` con inicializador

### Changed
- **Requisitos de Plataforma Actualizados**:
  - macOS: `10.13+` → `12.0+` (para soporte de async/await y Task.sleep)
  - Actualizado en Package.swift y README.md

- **Dependencias de Tests**:
  - Test target ahora incluye todas las dependencias necesarias (HttpClient, Core, Github)

### Technical Details

#### Archivos Nuevos
- `Sources/HttpClient/RateLimit.swift` (93 líneas)
- `Sources/HttpClient/RateLimitHandler.swift` (112 líneas)
- `Sources/HttpClient/GitHub+RateLimit.swift` (131 líneas)
- `GITHUB_ACTIONS_GUIDE.md` (850+ líneas)
- `examples/basic-action/` (Proyecto completo de ejemplo)
- `CHANGELOG.md` (Este archivo)

#### Archivos Modificados
- `Sources/Core/Summary.swift`: De 54 líneas → 295 líneas
- `Sources/Core/Utils/SummaryWriteOptions.swift`: Agregado inicializador público
- `Sources/HttpClient/GitHub.swift`: Integración de RateLimitHandler
- `Tests/Github-toolkitTests/Github_toolkitTests.swift`: De 1 test → 19 tests
- `README.md`: De 3 líneas → 466 líneas
- `Package.swift`: Actualización de plataforma mínima

#### Estadísticas
- **+854 líneas de código nuevo** implementado
- **+850 líneas de documentación** agregadas
- **0 errores de compilación**
- **0 warnings**
- **4 directorios corregidos**
- **19 tests creados**

## [0.0.1] - 2023-XX-XX

### Added
- Implementación inicial del GitHub Toolkit
- Cliente HTTP con autenticación
- 39+ endpoints de la API de GitHub
- 63 modelos de datos
- Core toolkit para GitHub Actions
- Support para iOS 16+ y macOS 10.13+

---

## Próximas Versiones

### Planificado para v0.1.0
- [ ] GraphQL API support
- [ ] Webhooks handling
- [ ] GitHub Apps authentication
- [ ] Actions API (workflows, artifacts, cache)
- [ ] Secrets management API
- [ ] Packages/Container Registry API
- [ ] Code Scanning & Security APIs
- [ ] Gists API

### Planificado para v0.2.0
- [ ] Request caching layer
- [ ] Advanced pagination helpers
- [ ] Webhook signature validation
- [ ] More comprehensive test coverage
- [ ] DocC documentation
- [ ] CI/CD automation

---

[Unreleased]: https://github.com/devswiftzone/github-toolkit/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/devswiftzone/github-toolkit/releases/tag/v0.0.1

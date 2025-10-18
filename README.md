# GitHub Toolkit

[![Swift](https://img.shields.io/badge/Swift-5.8+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016%2B%20|%20macOS%2010.13%2B-blue.svg)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

Un SDK completo de Swift para interactuar con la API de GitHub y construir GitHub Actions personalizadas.

## Características

- **API REST de GitHub**: Cliente completo con 39+ endpoints organizados en 18 categorías
- **GitHub Actions Core**: Toolkit completo para construir GitHub Actions en Swift
- **Modelos de Datos**: 63+ modelos Codable para todas las entidades de GitHub
- **Async/Await**: API moderna con soporte completo para concurrencia
- **Type-Safe**: Enums y tipos fuertes para prevenir errores
- **Cross-Platform**: Compatible con iOS 16+ y macOS 10.13+

## Instalación

### Swift Package Manager

Agrega el paquete a tu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tu-usuario/github-toolkit.git", from: "1.0.0")
]
```

O en Xcode: File → Add Package Dependencies → Ingresa la URL del repositorio

## Uso

### API de GitHub

#### Inicialización

```swift
import Github

// Con token de acceso personal
let github = GitHub(accessToken: "ghp_tu_token_aquí")

// Sin autenticación (solo endpoints públicos)
let github = GitHub(type: .withoutToken)
```

#### Repositorios

```swift
// Obtener repositorios de un usuario
let repos = try await github.repositories(ownerID: "octocat")

// Obtener un repositorio específico
let repo = try await github.repository(ownerID: "octocat", repositoryName: "Hello-World")

// Crear un repositorio
let newRepo = NewRepository(
    name: "nuevo-repo",
    description: "Mi nuevo repositorio",
    private: false
)
try await github.createRepository(request: newRepo)

// Buscar repositorios
let results = try await github.searchRepositories(
    query: "swift toolkit",
    sort: .stars,
    order: .desc
)
```

#### Pull Requests

```swift
// Listar pull requests
let pulls = try await github.pulls(
    ownerID: "owner",
    repositoryName: "repo",
    state: .open
)

// Obtener un PR específico
let pr = try await github.pull(
    ownerID: "owner",
    repositoryName: "repo",
    number: 123
)
```

#### Issues

```swift
// Listar issues
let issues = try await github.issues(
    ownerID: "owner",
    repositoryName: "repo",
    state: .open
)

// Buscar issues
let searchResults = try await github.searchIssues(
    query: "is:issue is:open label:bug"
)
```

#### Releases

```swift
// Obtener releases
let releases = try await github.releases(
    ownerID: "owner",
    repositoryName: "repo"
)

// Obtener la última release
let latest = try await github.latestRelease(
    ownerID: "owner",
    repositoryName: "repo"
)
```

#### Usuarios

```swift
// Obtener usuario actual
let me = try await github.me()

// Obtener un usuario específico
let user = try await github.user(username: "octocat")

// Buscar usuarios
let users = try await github.searchUsers(query: "tom", sort: .followers)

// Seguidores y siguiendo
let followers = try await github.followers(username: "octocat")
let following = try await github.following(username: "octocat")
```

#### OAuth

```swift
// Autorizar con GitHub
let authURL = try github.authorize(
    clientID: "tu_client_id",
    redirectURI: "tu_redirect_uri",
    scopes: [.repo, .user, .gist]
)

// Abrir en el navegador
UIApplication.shared.open(authURL)
```

### GitHub Actions Core

#### Variables de Entorno

```swift
import Core

// Verificar si está ejecutándose en GitHub Actions
if Core.env.isRunningInGitHubActions() {
    print("Running in GitHub Actions!")
}

// Obtener información del workflow
let workflow = Core.env.getWorkflow()
let repository = Core.env.getRepository()
let event = Core.env.getEventName()
```

#### Inputs y Outputs

```swift
// Leer inputs del workflow
let token = try Core.getInput(
    "github-token",
    options: InputOptions(required: true)
)

let verboseMode = Core.getBooleanInput("verbose")

let tags = Core.getMultilineInput("tags")

// Establecer outputs
Core.setOutput(name: "status", value: "success")
Core.setOutput(name: "result", value: "42")
```

#### Logging y Anotaciones

```swift
// Mensajes informativos
Core.info(message: "Procesando archivos...")
Core.debug(message: "Debug info: \(someVariable)")

// Anotaciones
Core.warning(message: "Este endpoint está deprecated", file: "main.swift", line: 42)
Core.error(message: "Falló la validación", file: "validator.swift")
Core.notice(message: "Se encontraron 3 warnings")

// Agrupar output
Core.startGroup(name: "Instalando dependencias")
// ... comandos ...
Core.endGroup()

// O con closure
try Core.group(name: "Running Tests") {
    // ... tu código aquí ...
}
```

#### Resúmenes (Step Summaries)

```swift
// Crear un resumen Markdown para el workflow
let summary = Core.summary

summary
    .addHeading("Test Results", level: 1)
    .addRaw("Se ejecutaron **150 tests**", addEOL: true)
    .addSeparator()
    .addHeading("Estadísticas", level: 2)
    .addList([
        "✅ Pasaron: 145",
        "❌ Fallaron: 5",
        "⏭️ Omitidos: 0"
    ])
    .addSeparator()
    .addHeading("Cobertura de Código", level: 2)
    .addTable([
        ["Módulo", "Cobertura"],
        ["Core", "95%"],
        ["GitHub API", "87%"],
        ["HttpClient", "100%"]
    ])
    .addSeparator()
    .addCodeBlock("""
    func testExample() {
        XCTAssertEqual(result, expected)
    }
    """, language: "swift")

// Escribir al archivo de resumen
try summary.write()

// Limpiar el resumen
try summary.clear()
```

#### Estado y Secretos

```swift
// Guardar estado entre steps
Core.saveState(name: "processedFiles", value: "file1.txt,file2.txt")

// Recuperar estado en un step posterior
if let files = Core.getState(name: "processedFiles") {
    print("Archivos procesados: \(files)")
}

// Marcar valores como secretos (serán enmascarados en los logs)
Core.setSecret("mi_token_secreto")

// Exportar variables de entorno
Core.exportVariable(name: "CUSTOM_VAR", value: "custom_value")

// Agregar a PATH
Core.addPath("/usr/local/custom/bin")
```

#### Marcar como Fallido

```swift
// Marcar el step como fallido
if validationFailed {
    Core.setFailed(message: "La validación falló con 5 errores")
    // Esto establece el exit code a 1
}
```

## Estructura del Proyecto

```
Sources/
├── HttpClient/          # Cliente HTTP base
│   ├── GitHub.swift     # Cliente principal
│   ├── AuthorizationType.swift
│   ├── RequestError.swift
│   └── ...
├── Github/              # API de GitHub
│   ├── GitHubAPI/       # Endpoints organizados por categoría
│   │   ├── Repositories/
│   │   ├── Pull/
│   │   ├── Issue/
│   │   ├── User/
│   │   ├── Releases/
│   │   └── ...
│   └── Models/          # Modelos de datos
│       ├── Repository.swift
│       ├── User.swift
│       ├── Pull.swift
│       └── ...
├── Core/                # GitHub Actions Toolkit
│   ├── Environment.swift
│   ├── Input.swift
│   ├── Output.swift
│   ├── Logger.swift
│   ├── Summary.swift
│   └── ...
└── Github-toolkit/      # Paquete principal
    └── Github_toolkit.swift
```

## Endpoints Disponibles

### Repositorios
- Listar, buscar, crear, actualizar repositorios
- Colaboradores, forks, stargazers
- Tags, branches, contributors
- Temas (topics), lenguajes

### Pull Requests
- Listar, obtener, buscar pull requests
- Estados y reviews

### Issues
- Listar, buscar issues
- Labels, milestones, comments

### Releases
- Listar releases y assets
- Obtener release específico

### Usuarios
- Perfil de usuario
- Seguidores, siguiendo
- Búsqueda de usuarios

### Otros
- Discussions
- Notifications
- OAuth
- Licenses
- Gitignore templates
- Search (global)

## Modelos de Datos

Todos los modelos implementan `Codable` y usan `camelCase` automáticamente:

- `User`: Perfil completo de usuario
- `Repository`: Información detallada del repositorio
- `Pull`: Pull Request con metadata
- `Issue`: Issue con labels, milestone, etc.
- `Release`: Release con assets
- `Branch`, `Tag`, `Collaborator`
- `Discussion`, `Notification`
- Y muchos más...

## Manejo de Errores

```swift
do {
    let repos = try await github.repositories(ownerID: "octocat")
} catch let error as RequestError {
    switch error {
    case .notFound:
        print("Usuario no encontrado")
    case .notAuthorized:
        print("No autorizado - verifica tu token")
    case .validationFailed(let message):
        print("Error de validación: \(message)")
    case .unknown(let statusCode):
        print("Error desconocido: \(statusCode)")
    }
}
```

### Rate Limiting

GitHub tiene límites en el número de requests que puedes hacer por hora. Este SDK incluye manejo automático de rate limiting:

```swift
// Configurar rate limiting con auto-retry
let options = RateLimitOptions(
    autoRetry: true,         // Espera automáticamente cuando se alcanza el límite
    maxRetries: 3,           // Máximo número de reintentos
    throwOnLimit: false,     // No lanzar error, esperar y reintentar
    warningThreshold: 0.8    // Advertir cuando se use el 80% del límite
)

let github = GitHub(
    accessToken: "tu_token",
    rateLimitOptions: options
)

// Verificar manualmente el rate limit antes de una request
try await github.checkRateLimit()

// Obtener información del rate limit actual
if let rateLimit = await github.getCurrentRateLimit() {
    print("Remaining: \(rateLimit.remaining)/\(rateLimit.limit)")
    print("Resets at: \(rateLimit.reset)")
    print("Usage: \(rateLimit.usagePercentage)%")
}

// Obtener estado completo del rate limit
let status = try await github.getRateLimitStatus()
print("Core API: \(status.resources.core.remaining)/\(status.resources.core.limit)")
print("Search API: \(status.resources.search.remaining)/\(status.resources.search.limit)")
print("GraphQL API: \(status.resources.graphql.remaining)/\(status.resources.graphql.limit)")
```

El SDK automáticamente:
- Extrae información de rate limit de los headers de respuesta
- Advierte cuando te acercas al límite (configurable)
- Puede esperar automáticamente y reintentar cuando se alcanza el límite
- Lanza errores informativos con el tiempo de reset

## Requisitos

- Swift 5.8+
- iOS 16.0+ / macOS 12.0+
- Xcode 14.0+

## Dependencias

- [swift-http-types](https://github.com/apple/swift-http-types) - Sistema de tipos HTTP de Apple

## Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Autor

**Asiel Cabrera Gonzalez**

## Crear GitHub Actions con Swift

¿Quieres crear tus propias GitHub Actions usando Swift? Lee nuestra [**Guía Completa para Crear GitHub Actions con Swift**](GITHUB_ACTIONS_GUIDE.md).

La guía incluye:
- Tutorial paso a paso
- 3 ejemplos completos (básico, stats de repos, validador de PRs)
- Mejores prácticas
- Testing y debugging
- Publicación en GitHub Marketplace

También puedes ver el [ejemplo básico](examples/basic-action/) listo para usar como template.

## Agradecimientos

- Basado en la API REST de GitHub v3
- Inspirado en [@actions/core](https://github.com/actions/toolkit/tree/main/packages/core) y [@actions/github](https://github.com/actions/toolkit/tree/main/packages/github)

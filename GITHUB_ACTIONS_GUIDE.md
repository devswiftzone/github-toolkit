# Guía Completa: Crear GitHub Actions con Swift

Esta guía te enseñará cómo crear GitHub Actions personalizadas usando Swift y el **GitHub Toolkit**.

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Conceptos Básicos](#conceptos-básicos)
3. [Estructura de un GitHub Action](#estructura-de-un-github-action)
4. [Tutorial Paso a Paso](#tutorial-paso-a-paso)
5. [Ejemplos Completos](#ejemplos-completos)
6. [Mejores Prácticas](#mejores-prácticas)
7. [Debugging y Testing](#debugging-y-testing)
8. [Publicación](#publicación)

---

## Introducción

### ¿Por qué Swift para GitHub Actions?

- ✅ **Type-Safe**: Swift es fuertemente tipado, reduciendo errores en tiempo de ejecución
- ✅ **Async/Await**: Manejo nativo de operaciones asíncronas
- ✅ **Rápido**: Rendimiento comparable a C++
- ✅ **Moderno**: Características avanzadas del lenguaje
- ✅ **Cross-Platform**: Compatible con Linux y macOS
- ✅ **Ecosystem**: Acceso a Swift Package Manager

### Ventajas del GitHub Toolkit

El **github-toolkit** proporciona:
- API completa de GitHub (REST)
- Inputs/Outputs de workflow
- Logging y anotaciones
- Summaries (resúmenes Markdown)
- Variables de entorno
- Manejo de rate limiting
- Y mucho más...

---

## Conceptos Básicos

### Componentes de un GitHub Action

1. **`action.yml`**: Archivo de metadatos que define el action
2. **Código Swift**: La lógica de tu action
3. **Package.swift**: Dependencias y configuración del proyecto
4. **Dockerfile** (opcional): Para actions que usan Docker

### Tipos de GitHub Actions

1. **Composite Actions**: Combinan múltiples steps (usaremos este tipo)
2. **Docker Actions**: Se ejecutan en un contenedor Docker
3. **JavaScript Actions**: Escritas en Node.js

---

## Estructura de un GitHub Action

### Estructura de Directorios Recomendada

```
my-swift-action/
├── .github/
│   └── workflows/
│       └── test.yml          # Workflow para probar el action
├── Sources/
│   └── MyAction/
│       └── main.swift        # Código principal
├── Package.swift             # Configuración SPM
├── Package.resolved          # Lock file de dependencias
├── action.yml                # Definición del action
├── README.md                 # Documentación
└── LICENSE                   # Licencia
```

---

## Tutorial Paso a Paso

### Paso 1: Crear el Proyecto Swift

```bash
# Crear directorio
mkdir my-swift-action
cd my-swift-action

# Inicializar paquete Swift
swift package init --type executable --name MyAction
```

### Paso 2: Configurar Package.swift

Edita `Package.swift` para incluir el github-toolkit:

```swift
// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "MyAction",
    platforms: [.macOS(.v12)],
    dependencies: [
        // GitHub Toolkit
        .package(url: "https://github.com/devswiftzone/github-toolkit.git", from: "0.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "MyAction",
            dependencies: [
                .product(name: "Core", package: "github-toolkit"),
                .product(name: "Github", package: "github-toolkit"),
            ],
            path: "Sources"
        ),
    ]
)
```

### Paso 3: Escribir el Código del Action

Edita `Sources/main.swift`:

```swift
import Foundation
import Core
import Github

@main
struct MyAction {
    static func main() async throws {
        // ====================================
        // 1. LEER INPUTS
        // ====================================

        let name = try Core.getInput(
            "name",
            options: InputOptions(required: true)
        )

        let message = try Core.getInput(
            "message",
            options: InputOptions(required: false)
        )

        // Input booleano
        let verbose = Core.getBooleanInput("verbose")

        // ====================================
        // 2. LOGGING
        // ====================================

        Core.info(message: "Starting action...")

        if verbose {
            Core.debug(message: "Debug mode enabled")
            Core.debug(message: "Name: \(name)")
            Core.debug(message: "Message: \(message ?? "none")")
        }

        // ====================================
        // 3. LÓGICA PRINCIPAL
        // ====================================

        Core.startGroup(name: "Processing")

        // Simular trabajo
        let result = processData(name: name, message: message)

        Core.info(message: "Processed: \(result)")

        Core.endGroup()

        // ====================================
        // 4. CREAR SUMMARY
        // ====================================

        let summary = Core.summary

        summary
            .addHeading("Action Results", level: 1)
            .addRaw("Execution completed successfully!", addEOL: true)
            .addSeparator()
            .addHeading("Details", level: 2)
            .addList([
                "Name: \(name)",
                "Message: \(message ?? "N/A")",
                "Result: \(result)"
            ])
            .addSeparator()
            .addCodeBlock("""
            // Example usage
            uses: username/my-swift-action@v1
            with:
              name: '\(name)'
            """, language: "yaml")

        try summary.write()

        // ====================================
        // 5. ESTABLECER OUTPUTS
        // ====================================

        Core.setOutput(name: "result", value: result)
        Core.setOutput(name: "timestamp", value: ISO8601DateFormatter().string(from: Date()))

        // ====================================
        // 6. FINALIZAR
        // ====================================

        Core.info(message: "Action completed successfully! ✅")
    }

    static func processData(name: String, message: String?) -> String {
        if let message = message {
            return "Hello \(name)! \(message)"
        } else {
            return "Hello \(name)!"
        }
    }
}
```

### Paso 4: Crear action.yml

Crea el archivo `action.yml` en la raíz:

```yaml
name: 'My Swift Action'
description: 'Un GitHub Action personalizado escrito en Swift'
author: 'Tu Nombre'

# Icono y color que aparecerá en el marketplace
branding:
  icon: 'code'
  color: 'orange'

# Definir inputs
inputs:
  name:
    description: 'Nombre para saludar'
    required: true
  message:
    description: 'Mensaje adicional'
    required: false
    default: 'Welcome to Swift Actions!'
  verbose:
    description: 'Activar modo verbose'
    required: false
    default: 'false'

# Definir outputs
outputs:
  result:
    description: 'Resultado del procesamiento'
  timestamp:
    description: 'Timestamp de ejecución'

# Configuración de ejecución
runs:
  using: 'composite'
  steps:
    # Paso 1: Instalar Swift (en runners Ubuntu)
    - name: Install Swift
      if: runner.os == 'Linux'
      run: |
        sudo apt-get update
        sudo apt-get install -y wget
        wget https://download.swift.org/swift-5.9-release/ubuntu2204/swift-5.9-RELEASE/swift-5.9-RELEASE-ubuntu22.04.tar.gz
        tar xzf swift-5.9-RELEASE-ubuntu22.04.tar.gz
        sudo mv swift-5.9-RELEASE-ubuntu22.04 /usr/share/swift
        echo "/usr/share/swift/usr/bin" >> $GITHUB_PATH
      shell: bash

    # Paso 2: Compilar el action
    - name: Build Swift Action
      run: |
        cd ${{ github.action_path }}
        swift build -c release
      shell: bash

    # Paso 3: Ejecutar el action
    - name: Run Action
      env:
        INPUT_NAME: ${{ inputs.name }}
        INPUT_MESSAGE: ${{ inputs.message }}
        INPUT_VERBOSE: ${{ inputs.verbose }}
      run: |
        cd ${{ github.action_path }}
        swift run -c release
      shell: bash
```

### Paso 5: Crear Workflow de Prueba

Crea `.github/workflows/test.yml`:

```yaml
name: Test Action

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  test-action:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run My Swift Action
        uses: ./
        with:
          name: 'GitHub Actions'
          message: 'Testing Swift Action!'
          verbose: 'true'
```

### Paso 6: Compilar y Probar Localmente

```bash
# Compilar
swift build

# Probar localmente (simular environment)
export INPUT_NAME="Test User"
export INPUT_MESSAGE="Hello from local test"
export INPUT_VERBOSE="true"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"

swift run

# Ver el summary generado
cat /tmp/summary.md
```

---

## Ejemplos Completos

### Ejemplo 1: Action que usa la API de GitHub

```swift
import Foundation
import Core
import Github

@main
struct RepoStatsAction {
    static func main() async throws {
        // Leer inputs
        let token = try Core.getInput("github-token", options: InputOptions(required: true))
        let repo = try Core.getInput("repository", options: InputOptions(required: true))

        // Ocultar el token en los logs
        Core.setSecret(token)

        Core.info(message: "Fetching stats for \(repo)")

        // Separar owner/repo
        let parts = repo.split(separator: "/")
        guard parts.count == 2 else {
            Core.setFailed(message: "Invalid repository format. Use: owner/repo")
            return
        }

        let owner = String(parts[0])
        let repoName = String(parts[1])

        // Crear cliente GitHub
        let github = GitHub(accessToken: token)

        Core.startGroup(name: "Fetching Repository Data")

        do {
            // Obtener información del repositorio
            let repository = try await github.repository(ownerID: owner, repositoryName: repoName)

            Core.info(message: "Repository: \(repository.fullName)")
            Core.info(message: "Stars: \(repository.stargazersCount ?? 0)")
            Core.info(message: "Forks: \(repository.forksCount ?? 0)")

            // Obtener pull requests
            let pulls = try await github.pulls(
                ownerID: owner,
                repositoryName: repoName,
                state: .open
            )

            Core.info(message: "Open PRs: \(pulls.count)")

            // Obtener issues
            let issues = try await github.issues(
                ownerID: owner,
                repositoryName: repoName,
                state: .open
            )

            Core.info(message: "Open Issues: \(issues.count)")

            Core.endGroup()

            // Crear summary
            let summary = Core.summary

            summary
                .addHeading("📊 Repository Statistics", level: 1)
                .addRaw("Repository: **\(repository.fullName)**", addEOL: true)
                .addSeparator()
                .addHeading("Stats", level: 2)
                .addTable([
                    ["Metric", "Value"],
                    ["⭐ Stars", "\(repository.stargazersCount ?? 0)"],
                    ["🍴 Forks", "\(repository.forksCount ?? 0)"],
                    ["👀 Watchers", "\(repository.watchersCount ?? 0)"],
                    ["🔓 Open Issues", "\(issues.count)"],
                    ["🔀 Open PRs", "\(pulls.count)"],
                ])

            if let description = repository.description {
                summary
                    .addSeparator()
                    .addHeading("Description", level: 2)
                    .addQuote(description)
            }

            try summary.write()

            // Outputs
            Core.setOutput(name: "stars", value: "\(repository.stargazersCount ?? 0)")
            Core.setOutput(name: "forks", value: "\(repository.forksCount ?? 0)")
            Core.setOutput(name: "open-issues", value: "\(issues.count)")
            Core.setOutput(name: "open-prs", value: "\(pulls.count)")

            Core.info(message: "Stats fetched successfully! ✅")

        } catch {
            Core.setFailed(message: "Failed to fetch repository stats: \(error)")
        }
    }
}
```

**action.yml correspondiente:**

```yaml
name: 'Repository Stats'
description: 'Get GitHub repository statistics'

inputs:
  github-token:
    description: 'GitHub token'
    required: true
  repository:
    description: 'Repository in format owner/repo'
    required: true

outputs:
  stars:
    description: 'Number of stars'
  forks:
    description: 'Number of forks'
  open-issues:
    description: 'Number of open issues'
  open-prs:
    description: 'Number of open pull requests'

runs:
  using: 'composite'
  steps:
    - name: Install Swift
      if: runner.os == 'Linux'
      run: |
        # Instalar Swift...
      shell: bash

    - name: Build and Run
      env:
        INPUT_GITHUB-TOKEN: ${{ inputs.github-token }}
        INPUT_REPOSITORY: ${{ inputs.repository }}
      run: |
        cd ${{ github.action_path }}
        swift build -c release
        swift run -c release
      shell: bash
```

**Uso:**

```yaml
- name: Get Repository Stats
  uses: username/repo-stats-action@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    repository: 'devswiftzone/github-toolkit'
```

### Ejemplo 2: Action con Rate Limiting

```swift
import Foundation
import Core
import Github

@main
struct BatchProcessorAction {
    static func main() async throws {
        let token = try Core.getInput("github-token", options: InputOptions(required: true))
        let repos = Core.getMultilineInput("repositories")

        Core.setSecret(token)

        Core.info(message: "Processing \(repos.count) repositories")

        // Configurar rate limiting
        let rateLimitOptions = RateLimitOptions(
            autoRetry: true,
            maxRetries: 3,
            throwOnLimit: false,
            warningThreshold: 0.8
        )

        let github = GitHub(accessToken: token, rateLimitOptions: rateLimitOptions)

        var results: [String] = []

        for (index, repo) in repos.enumerated() {
            Core.info(message: "[\(index + 1)/\(repos.count)] Processing \(repo)")

            // Verificar rate limit antes de cada request
            if let rateLimit = await github.getCurrentRateLimit() {
                Core.info(message: "Rate Limit: \(rateLimit.remaining)/\(rateLimit.limit)")

                if rateLimit.remaining < 10 {
                    Core.warning(message: "Low rate limit! Only \(rateLimit.remaining) requests remaining")
                }
            }

            let parts = repo.split(separator: "/")
            guard parts.count == 2 else {
                Core.warning(message: "Skipping invalid repo format: \(repo)")
                continue
            }

            do {
                let repository = try await github.repository(
                    ownerID: String(parts[0]),
                    repositoryName: String(parts[1])
                )

                results.append("✅ \(repository.fullName): \(repository.stargazersCount ?? 0) stars")

            } catch {
                Core.error(message: "Failed to process \(repo): \(error)")
                results.append("❌ \(repo): Error")
            }
        }

        // Summary
        let summary = Core.summary
        summary
            .addHeading("Batch Processing Results", level: 1)
            .addList(results)

        try summary.write()

        Core.info(message: "Batch processing complete!")
    }
}
```

### Ejemplo 3: Action con Validación de PRs

```swift
import Foundation
import Core
import Github

@main
struct PRValidatorAction {
    static func main() async throws {
        let token = try Core.getInput("github-token", options: InputOptions(required: true))

        // Obtener info del PR desde el ambiente
        guard let eventPath = Core.env.getEventPath(),
              let eventData = try? Data(contentsOf: URL(fileURLWithPath: eventPath)),
              let event = try? JSONDecoder().decode(PullRequestEvent.self, from: eventData) else {
            Core.setFailed(message: "This action must be triggered by a pull_request event")
            return
        }

        Core.info(message: "Validating PR #\(event.number)")

        let github = GitHub(accessToken: token)

        var validations: [Validation] = []

        // Validación 1: Título
        if event.pullRequest.title.count < 10 {
            validations.append(Validation(
                name: "Title Length",
                passed: false,
                message: "Title should be at least 10 characters"
            ))
        } else {
            validations.append(Validation(
                name: "Title Length",
                passed: true,
                message: "Title is descriptive"
            ))
        }

        // Validación 2: Descripción
        if let body = event.pullRequest.body, !body.isEmpty {
            validations.append(Validation(
                name: "Has Description",
                passed: true,
                message: "PR has a description"
            ))
        } else {
            validations.append(Validation(
                name: "Has Description",
                passed: false,
                message: "PR should have a description"
            ))
        }

        // Validación 3: Tamaño del PR
        let changedFiles = event.pullRequest.changedFiles ?? 0
        if changedFiles > 20 {
            validations.append(Validation(
                name: "PR Size",
                passed: false,
                message: "PR changes \(changedFiles) files. Consider splitting it."
            ))
        } else {
            validations.append(Validation(
                name: "PR Size",
                passed: true,
                message: "PR size is reasonable (\(changedFiles) files)"
            ))
        }

        // Crear summary
        let summary = Core.summary
        let passedCount = validations.filter { $0.passed }.count
        let totalCount = validations.count

        summary
            .addHeading("PR Validation Results", level: 1)
            .addRaw("Score: **\(passedCount)/\(totalCount)** validations passed", addEOL: true)
            .addSeparator()
            .addHeading("Checks", level: 2)

        for validation in validations {
            let icon = validation.passed ? "✅" : "❌"
            summary.addRaw("\(icon) **\(validation.name)**: \(validation.message)", addEOL: true)
        }

        try summary.write()

        // Reportar resultados
        let allPassed = validations.allSatisfy { $0.passed }

        if allPassed {
            Core.info(message: "All validations passed! ✅")
        } else {
            let failed = validations.filter { !$0.passed }
            for validation in failed {
                Core.warning(message: "\(validation.name): \(validation.message)")
            }
            Core.setFailed(message: "\(totalCount - passedCount) validation(s) failed")
        }
    }
}

struct PullRequestEvent: Codable {
    let number: Int
    let pullRequest: PullRequestData

    enum CodingKeys: String, CodingKey {
        case number
        case pullRequest = "pull_request"
    }
}

struct PullRequestData: Codable {
    let title: String
    let body: String?
    let changedFiles: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case changedFiles = "changed_files"
    }
}

struct Validation {
    let name: String
    let passed: Bool
    let message: String
}
```

---

## Mejores Prácticas

### 1. Manejo de Errores

```swift
// ✅ BUENO - Manejo apropiado
do {
    let result = try await fetchData()
    Core.setOutput(name: "result", value: result)
} catch {
    Core.setFailed(message: "Failed to fetch data: \(error.localizedDescription)")
    return
}

// ❌ MALO - Force unwrap
let result = try! fetchData()  // Puede crashear el action
```

### 2. Logging Apropiado

```swift
// ✅ BUENO - Logging estructurado
Core.startGroup(name: "Data Processing")
Core.info(message: "Processing \(items.count) items")

for item in items {
    Core.debug(message: "Processing item: \(item.id)")
    // ...
}

Core.endGroup()

// ❌ MALO - Sin contexto
print("Processing...")  // No usa el sistema de logging de Actions
```

### 3. Secrets

```swift
// ✅ BUENO - Marcar secrets
let token = try Core.getInput("github-token", options: InputOptions(required: true))
Core.setSecret(token)  // El token no aparecerá en los logs

// ❌ MALO - Exponer secrets
Core.info(message: "Using token: \(token)")  // ¡Nunca hagas esto!
```

### 4. Inputs con Validación

```swift
// ✅ BUENO - Validar inputs
let timeout = try Core.getInput("timeout")
guard let timeoutValue = Int(timeout), timeoutValue > 0, timeoutValue <= 3600 else {
    Core.setFailed(message: "timeout must be a number between 1 and 3600")
    return
}

// ❌ MALO - Asumir que el input es válido
let timeout = Int(try Core.getInput("timeout"))!  // Puede crashear
```

### 5. Summaries Informativos

```swift
// ✅ BUENO - Summary detallado
let summary = Core.summary
summary
    .addHeading("Results", level: 1)
    .addTable([
        ["Metric", "Value"],
        ["Processed", "\(count)"],
        ["Succeeded", "\(succeeded)"],
        ["Failed", "\(failed)"]
    ])
    .addSeparator()
    .addHeading("Next Steps", level: 2)
    .addList([
        "Review failed items",
        "Check logs for errors"
    ])

try summary.write()

// ❌ MALO - Summary vacío o poco útil
Core.summary.addRaw("Done").write()
```

### 6. Rate Limiting

```swift
// ✅ BUENO - Configurar rate limiting
let options = RateLimitOptions(
    autoRetry: true,
    warningThreshold: 0.8
)
let github = GitHub(accessToken: token, rateLimitOptions: options)

// Verificar antes de operaciones masivas
if let rateLimit = await github.getCurrentRateLimit() {
    if rateLimit.remaining < 100 {
        Core.warning(message: "Low rate limit: \(rateLimit.remaining)")
    }
}

// ❌ MALO - No considerar rate limits
// Hacer cientos de requests sin verificar puede fallar
```

---

## Debugging y Testing

### Testing Local

Crea un script `test-local.sh`:

```bash
#!/bin/bash

# Simular environment de GitHub Actions
export INPUT_NAME="Test User"
export INPUT_MESSAGE="Hello from test"
export GITHUB_STEP_SUMMARY="/tmp/github-summary.md"
export GITHUB_OUTPUT="/tmp/github-output.txt"
export GITHUB_ENV="/tmp/github-env.txt"
export GITHUB_ACTIONS="true"
export GITHUB_WORKFLOW="Test Workflow"
export GITHUB_REPOSITORY="owner/repo"

# Crear archivos temporales
touch $GITHUB_STEP_SUMMARY
touch $GITHUB_OUTPUT
touch $GITHUB_ENV

# Ejecutar
swift run

# Mostrar resultados
echo ""
echo "=== SUMMARY ==="
cat $GITHUB_STEP_SUMMARY

echo ""
echo "=== OUTPUTS ==="
cat $GITHUB_OUTPUT

echo ""
echo "=== ENV ==="
cat $GITHUB_ENV

# Limpiar
rm -f $GITHUB_STEP_SUMMARY $GITHUB_OUTPUT $GITHUB_ENV
```

Ejecutar:

```bash
chmod +x test-local.sh
./test-local.sh
```

### Testing en CI

Crea `.github/workflows/ci.yml`:

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: swift build

      - name: Run Tests
        run: swift test

      - name: Test Action
        uses: ./
        with:
          name: 'CI Test'
          message: 'Testing on ${{ matrix.os }}'
```

### Debugging con Act

[Act](https://github.com/nektos/act) permite ejecutar GitHub Actions localmente:

```bash
# Instalar act
brew install act

# Ejecutar workflow
act -j test-action

# Con secrets
act -j test-action -s GITHUB_TOKEN=ghp_xxxxx
```

---

## Publicación

### 1. Versionado Semántico

Usa tags para versionar tu action:

```bash
# Crear release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Actualizar major version tag
git tag -fa v1 -m "Update v1 tag"
git push origin v1 --force
```

### 2. GitHub Marketplace

1. Agrega metadata a `action.yml`:

```yaml
name: 'My Swift Action'
description: 'Detailed description of what your action does'
author: 'Your Name'

branding:
  icon: 'code'  # Ver: https://feathericons.com
  color: 'orange'  # blue, green, orange, red, purple, gray-dark
```

2. Crea un README completo

3. Ve a tu repositorio → Releases → "Draft a new release"

4. Marca "Publish this Action to the GitHub Marketplace"

### 3. README Template

```markdown
# My Swift Action

Brief description of what your action does.

## Usage

\`\`\`yaml
- uses: username/my-swift-action@v1
  with:
    name: 'World'
    message: 'Hello!'
\`\`\`

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `name` | Name to greet | Yes | N/A |
| `message` | Custom message | No | `Welcome!` |

## Outputs

| Output | Description |
|--------|-------------|
| `result` | Processing result |
| `timestamp` | Execution timestamp |

## Examples

### Example 1: Basic Usage

\`\`\`yaml
- uses: username/my-swift-action@v1
  with:
    name: 'GitHub'
\`\`\`

### Example 2: With All Options

\`\`\`yaml
- uses: username/my-swift-action@v1
  with:
    name: 'World'
    message: 'Custom greeting'
    verbose: true
\`\`\`

## License

MIT
```

---

## Recursos Adicionales

### Documentación

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Creating Actions](https://docs.github.com/en/actions/creating-actions)
- [Swift.org](https://swift.org)

### Repositorios de Ejemplo

- [Test_Github_Action](https://github.com/asielcabrera/Test_Github_Action) - Action simple
- [github-toolkit](https://github.com/devswiftzone/github-toolkit) - El toolkit completo

### Comunidad

- [GitHub Community](https://github.community)
- [Swift Forums](https://forums.swift.org)

---

## Conclusión

Crear GitHub Actions con Swift es una forma poderosa y type-safe de automatizar workflows. Con el **github-toolkit**, tienes acceso a:

- ✅ API completa de GitHub
- ✅ Inputs/Outputs manejados
- ✅ Logging profesional
- ✅ Summaries ricos en Markdown
- ✅ Rate limiting inteligente
- ✅ Y mucho más...

¡Empieza a construir tus propios actions hoy!

---

**¿Preguntas o problemas?** Abre un issue en [github-toolkit](https://github.com/devswiftzone/github-toolkit/issues)

# Basic Swift Action

Un template básico para crear GitHub Actions con Swift usando github-toolkit.

## Uso

```yaml
- uses: username/basic-action@v1
  with:
    name: 'World'
    greeting: 'Hello'
    verbose: 'true'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `name` | Name to greet | Yes | N/A |
| `greeting` | Custom greeting message | No | `Hello` |
| `verbose` | Enable verbose logging | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `message` | The generated greeting message |
| `timestamp` | Timestamp of execution (ISO 8601) |

## Desarrollo Local

### Requisitos

- Swift 5.8+
- macOS 12+ o Ubuntu 22.04+

### Compilar

```bash
swift build
```

### Probar Localmente

```bash
# Configurar environment
export INPUT_NAME="Test User"
export INPUT_GREETING="Hi"
export INPUT_VERBOSE="true"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"
export GITHUB_OUTPUT="/tmp/output.txt"

# Ejecutar
swift run

# Ver resultados
cat /tmp/summary.md
cat /tmp/output.txt
```

## Estructura del Proyecto

```
basic-action/
├── Sources/
│   └── main.swift       # Código principal del action
├── Package.swift        # Configuración de dependencias
├── action.yml          # Metadata del action
└── README.md           # Este archivo
```

## Licencia

MIT

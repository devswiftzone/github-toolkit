# Basic Swift Action

A basic template for creating GitHub Actions with Swift using github-toolkit.

## Usage

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

## Local Development

### Requirements

- Swift 5.8+
- macOS 12+ or Ubuntu 22.04+

### Build

```bash
swift build
```

### Test Locally

```bash
# Configure environment
export INPUT_NAME="Test User"
export INPUT_GREETING="Hi"
export INPUT_VERBOSE="true"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"
export GITHUB_OUTPUT="/tmp/output.txt"

# Run
swift run

# View results
cat /tmp/summary.md
cat /tmp/output.txt
```

## Project Structure

```
basic-action/
├── Sources/
│   └── main.swift       # Main action code
├── Package.swift        # Dependencies configuration
├── action.yml          # Action metadata
└── README.md           # This file
```

## License

MIT

# Complete Guide: Creating GitHub Actions with Swift

This guide will teach you how to create custom GitHub Actions using Swift and the **GitHub Toolkit**.

## Table of Contents

1. [Introduction](#introduction)
2. [Basic Concepts](#basic-concepts)
3. [GitHub Action Structure](#github-action-structure)
4. [Step-by-Step Tutorial](#step-by-step-tutorial)
5. [Complete Examples](#complete-examples)
6. [Best Practices](#best-practices)
7. [Debugging and Testing](#debugging-and-testing)
8. [Publishing](#publishing)

---

## Introduction

### Why Swift for GitHub Actions?

- ✅ **Type-Safe**: Swift is strongly typed, reducing runtime errors
- ✅ **Async/Await**: Native handling of asynchronous operations
- ✅ **Fast**: Performance comparable to C++
- ✅ **Modern**: Advanced language features
- ✅ **Cross-Platform**: Compatible with Linux and macOS
- ✅ **Ecosystem**: Access to Swift Package Manager

### GitHub Toolkit Advantages

The **github-toolkit** provides:
- Complete GitHub API (REST)
- Workflow inputs/outputs
- Logging and annotations
- Summaries (Markdown summaries)
- Environment variables
- Rate limiting handling
- And much more...

---

## Basic Concepts

### GitHub Action Components

1. **`action.yml`**: Metadata file that defines the action
2. **Swift Code**: Your action's logic
3. **Package.swift**: Project dependencies and configuration
4. **Dockerfile** (optional): For actions that use Docker

### Types of GitHub Actions

1. **Composite Actions**: Combine multiple steps (we'll use this type)
2. **Docker Actions**: Run in a Docker container
3. **JavaScript Actions**: Written in Node.js

---

## GitHub Action Structure

### Recommended Directory Structure

```
my-swift-action/
├── .github/
│   └── workflows/
│       └── test.yml          # Workflow to test the action
├── Sources/
│   └── MyAction/
│       └── main.swift        # Main code
├── Package.swift             # SPM configuration
├── Package.resolved          # Dependencies lock file
├── action.yml                # Action definition
├── README.md                 # Documentation
└── LICENSE                   # License
```

---

## Step-by-Step Tutorial

### Step 1: Create the Swift Project

```bash
# Create directory
mkdir my-swift-action
cd my-swift-action

# Initialize Swift package
swift package init --type executable --name MyAction
```

### Step 2: Configure Package.swift

Edit `Package.swift` to include github-toolkit:

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

### Step 3: Write the Action Code

Edit `Sources/main.swift`:

```swift
import Foundation
import Core
import Github

@main
struct MyAction {
    static func main() async throws {
        // ====================================
        // 1. READ INPUTS
        // ====================================

        let name = try Core.getInput(
            "name",
            options: InputOptions(required: true)
        )

        let message = try Core.getInput(
            "message",
            options: InputOptions(required: false)
        )

        // Boolean input
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
        // 3. MAIN LOGIC
        // ====================================

        Core.startGroup(name: "Processing")

        // Simulate work
        let result = processData(name: name, message: message)

        Core.info(message: "Processed: \(result)")

        Core.endGroup()

        // ====================================
        // 4. CREATE SUMMARY
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
        // 5. SET OUTPUTS
        // ====================================

        Core.setOutput(name: "result", value: result)
        Core.setOutput(name: "timestamp", value: ISO8601DateFormatter().string(from: Date()))

        // ====================================
        // 6. FINISH
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

### Step 4: Create action.yml

Create the `action.yml` file in the root:

```yaml
name: 'My Swift Action'
description: 'A custom GitHub Action written in Swift'
author: 'Your Name'

# Icon and color that will appear in the marketplace
branding:
  icon: 'code'
  color: 'orange'

# Define inputs
inputs:
  name:
    description: 'Name to greet'
    required: true
  message:
    description: 'Additional message'
    required: false
    default: 'Welcome to Swift Actions!'
  verbose:
    description: 'Enable verbose mode'
    required: false
    default: 'false'

# Define outputs
outputs:
  result:
    description: 'Processing result'
  timestamp:
    description: 'Execution timestamp'

# Execution configuration
runs:
  using: 'composite'
  steps:
    # Step 1: Install Swift (on Ubuntu runners)
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

    # Step 2: Build the action
    - name: Build Swift Action
      run: |
        cd ${{ github.action_path }}
        swift build -c release
      shell: bash

    # Step 3: Run the action
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

### Step 5: Create Test Workflow

Create `.github/workflows/test.yml`:

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

### Step 6: Build and Test Locally

```bash
# Build
swift build

# Test locally (simulate environment)
export INPUT_NAME="Test User"
export INPUT_MESSAGE="Hello from local test"
export INPUT_VERBOSE="true"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"

swift run

# View generated summary
cat /tmp/summary.md
```

---

## Complete Examples

### Example 1: Action that Uses the GitHub API

```swift
import Foundation
import Core
import Github

@main
struct RepoStatsAction {
    static func main() async throws {
        // Read inputs
        let token = try Core.getInput("github-token", options: InputOptions(required: true))
        let repo = try Core.getInput("repository", options: InputOptions(required: true))

        // Hide token in logs
        Core.setSecret(token)

        Core.info(message: "Fetching stats for \(repo)")

        // Separate owner/repo
        let parts = repo.split(separator: "/")
        guard parts.count == 2 else {
            Core.setFailed(message: "Invalid repository format. Use: owner/repo")
            return
        }

        let owner = String(parts[0])
        let repoName = String(parts[1])

        // Create GitHub client
        let github = GitHub(accessToken: token)

        Core.startGroup(name: "Fetching Repository Data")

        do {
            // Get repository information
            let repository = try await github.repository(ownerID: owner, repositoryName: repoName)

            Core.info(message: "Repository: \(repository.fullName)")
            Core.info(message: "Stars: \(repository.stargazersCount ?? 0)")
            Core.info(message: "Forks: \(repository.forksCount ?? 0)")

            // Get pull requests
            let pulls = try await github.pulls(
                ownerID: owner,
                repositoryName: repoName,
                state: .open
            )

            Core.info(message: "Open PRs: \(pulls.count)")

            // Get issues
            let issues = try await github.issues(
                ownerID: owner,
                repositoryName: repoName,
                state: .open
            )

            Core.info(message: "Open Issues: \(issues.count)")

            Core.endGroup()

            // Create summary
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

**Corresponding action.yml:**

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
        # Install Swift...
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

**Usage:**

```yaml
- name: Get Repository Stats
  uses: username/repo-stats-action@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    repository: 'devswiftzone/github-toolkit'
```

### Example 2: Action with Rate Limiting

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

        // Configure rate limiting
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

            // Check rate limit before each request
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

### Example 3: Action with PR Validation

```swift
import Foundation
import Core
import Github

@main
struct PRValidatorAction {
    static func main() async throws {
        let token = try Core.getInput("github-token", options: InputOptions(required: true))

        // Get PR info from environment
        guard let eventPath = Core.env.getEventPath(),
              let eventData = try? Data(contentsOf: URL(fileURLWithPath: eventPath)),
              let event = try? JSONDecoder().decode(PullRequestEvent.self, from: eventData) else {
            Core.setFailed(message: "This action must be triggered by a pull_request event")
            return
        }

        Core.info(message: "Validating PR #\(event.number)")

        let github = GitHub(accessToken: token)

        var validations: [Validation] = []

        // Validation 1: Title
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

        // Validation 2: Description
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

        // Validation 3: PR Size
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

        // Create summary
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

        // Report results
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

## Best Practices

### 1. Error Handling

```swift
// ✅ GOOD - Proper handling
do {
    let result = try await fetchData()
    Core.setOutput(name: "result", value: result)
} catch {
    Core.setFailed(message: "Failed to fetch data: \(error.localizedDescription)")
    return
}

// ❌ BAD - Force unwrap
let result = try! fetchData()  // Can crash the action
```

### 2. Proper Logging

```swift
// ✅ GOOD - Structured logging
Core.startGroup(name: "Data Processing")
Core.info(message: "Processing \(items.count) items")

for item in items {
    Core.debug(message: "Processing item: \(item.id)")
    // ...
}

Core.endGroup()

// ❌ BAD - No context
print("Processing...")  // Doesn't use Actions logging system
```

### 3. Secrets

```swift
// ✅ GOOD - Mark secrets
let token = try Core.getInput("github-token", options: InputOptions(required: true))
Core.setSecret(token)  // Token won't appear in logs

// ❌ BAD - Expose secrets
Core.info(message: "Using token: \(token)")  // Never do this!
```

### 4. Inputs with Validation

```swift
// ✅ GOOD - Validate inputs
let timeout = try Core.getInput("timeout")
guard let timeoutValue = Int(timeout), timeoutValue > 0, timeoutValue <= 3600 else {
    Core.setFailed(message: "timeout must be a number between 1 and 3600")
    return
}

// ❌ BAD - Assume input is valid
let timeout = Int(try Core.getInput("timeout"))!  // Can crash
```

### 5. Informative Summaries

```swift
// ✅ GOOD - Detailed summary
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

// ❌ BAD - Empty or unhelpful summary
Core.summary.addRaw("Done").write()
```

### 6. Rate Limiting

```swift
// ✅ GOOD - Configure rate limiting
let options = RateLimitOptions(
    autoRetry: true,
    warningThreshold: 0.8
)
let github = GitHub(accessToken: token, rateLimitOptions: options)

// Check before bulk operations
if let rateLimit = await github.getCurrentRateLimit() {
    if rateLimit.remaining < 100 {
        Core.warning(message: "Low rate limit: \(rateLimit.remaining)")
    }
}

// ❌ BAD - Don't consider rate limits
// Making hundreds of requests without checking can fail
```

---

## Debugging and Testing

### Local Testing

Create a `test-local.sh` script:

```bash
#!/bin/bash

# Simulate GitHub Actions environment
export INPUT_NAME="Test User"
export INPUT_MESSAGE="Hello from test"
export GITHUB_STEP_SUMMARY="/tmp/github-summary.md"
export GITHUB_OUTPUT="/tmp/github-output.txt"
export GITHUB_ENV="/tmp/github-env.txt"
export GITHUB_ACTIONS="true"
export GITHUB_WORKFLOW="Test Workflow"
export GITHUB_REPOSITORY="owner/repo"

# Create temporary files
touch $GITHUB_STEP_SUMMARY
touch $GITHUB_OUTPUT
touch $GITHUB_ENV

# Execute
swift run

# Show results
echo ""
echo "=== SUMMARY ==="
cat $GITHUB_STEP_SUMMARY

echo ""
echo "=== OUTPUTS ==="
cat $GITHUB_OUTPUT

echo ""
echo "=== ENV ==="
cat $GITHUB_ENV

# Cleanup
rm -f $GITHUB_STEP_SUMMARY $GITHUB_OUTPUT $GITHUB_ENV
```

Execute:

```bash
chmod +x test-local.sh
./test-local.sh
```

### Testing in CI

Create `.github/workflows/ci.yml`:

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

### Debugging with Act

[Act](https://github.com/nektos/act) allows you to run GitHub Actions locally:

```bash
# Install act
brew install act

# Run workflow
act -j test-action

# With secrets
act -j test-action -s GITHUB_TOKEN=ghp_xxxxx
```

---

## Publishing

### 1. Semantic Versioning

Use tags to version your action:

```bash
# Create release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Update major version tag
git tag -fa v1 -m "Update v1 tag"
git push origin v1 --force
```

### 2. GitHub Marketplace

1. Add metadata to `action.yml`:

```yaml
name: 'My Swift Action'
description: 'Detailed description of what your action does'
author: 'Your Name'

branding:
  icon: 'code'  # See: https://feathericons.com
  color: 'orange'  # blue, green, orange, red, purple, gray-dark
```

2. Create a complete README

3. Go to your repository → Releases → "Draft a new release"

4. Check "Publish this Action to the GitHub Marketplace"

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

## Additional Resources

### Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Creating Actions](https://docs.github.com/en/actions/creating-actions)
- [Swift.org](https://swift.org)

### Example Repositories

- [Test_Github_Action](https://github.com/asielcabrera/Test_Github_Action) - Simple action
- [github-toolkit](https://github.com/devswiftzone/github-toolkit) - The complete toolkit

### Community

- [GitHub Community](https://github.community)
- [Swift Forums](https://forums.swift.org)

---

## Conclusion

Creating GitHub Actions with Swift is a powerful and type-safe way to automate workflows. With the **github-toolkit**, you have access to:

- ✅ Complete GitHub API
- ✅ Managed inputs/outputs
- ✅ Professional logging
- ✅ Rich Markdown summaries
- ✅ Intelligent rate limiting
- ✅ And much more...

Start building your own actions today!

---

**Questions or issues?** Open an issue at [github-toolkit](https://github.com/devswiftzone/github-toolkit/issues)

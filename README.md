# GitHub Toolkit

[![Swift](https://img.shields.io/badge/Swift-5.8+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016%2B%20|%20macOS%2012.0%2B-blue.svg)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

A comprehensive Swift SDK for interacting with the GitHub API and building custom GitHub Actions.

## Features

- **GitHub REST API**: Complete client with 39+ endpoints organized in 18 categories
- **GitHub Actions Core**: Complete toolkit for building GitHub Actions in Swift
- **Data Models**: 63+ Codable models for all GitHub entities
- **Async/Await**: Modern API with full concurrency support
- **Type-Safe**: Strong enums and types to prevent errors
- **Cross-Platform**: Compatible with iOS 16+ and macOS 12.0+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/devswiftzone/github-toolkit.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL

## Usage

### GitHub API

#### Initialization

```swift
import Github

// With personal access token
let github = GitHub(accessToken: "ghp_your_token_here")

// Without authentication (public endpoints only)
let github = GitHub(type: .withoutToken)
```

#### Repositories

```swift
// Get user repositories
let repos = try await github.repositories(ownerID: "octocat")

// Get a specific repository
let repo = try await github.repository(ownerID: "octocat", repositoryName: "Hello-World")

// Create a repository
let newRepo = NewRepository(
    name: "new-repo",
    description: "My new repository",
    private: false
)
try await github.createRepository(request: newRepo)

// Search repositories
let results = try await github.searchRepositories(
    query: "swift toolkit",
    sort: .stars,
    order: .desc
)
```

#### Pull Requests

```swift
// List pull requests
let pulls = try await github.pulls(
    ownerID: "owner",
    repositoryName: "repo",
    state: .open
)

// Get a specific PR
let pr = try await github.pull(
    ownerID: "owner",
    repositoryName: "repo",
    number: 123
)
```

#### Issues

```swift
// List issues
let issues = try await github.issues(
    ownerID: "owner",
    repositoryName: "repo",
    state: .open
)

// Search issues
let searchResults = try await github.searchIssues(
    query: "is:issue is:open label:bug"
)
```

#### Releases

```swift
// Get releases
let releases = try await github.releases(
    ownerID: "owner",
    repositoryName: "repo"
)

// Get latest release
let latest = try await github.latestRelease(
    ownerID: "owner",
    repositoryName: "repo"
)
```

#### Users

```swift
// Get current user
let me = try await github.me()

// Get a specific user
let user = try await github.user(username: "octocat")

// Search users
let users = try await github.searchUsers(query: "tom", sort: .followers)

// Followers and following
let followers = try await github.followers(username: "octocat")
let following = try await github.following(username: "octocat")
```

#### OAuth

```swift
// Authorize with GitHub
let authURL = try github.authorize(
    clientID: "your_client_id",
    redirectURI: "your_redirect_uri",
    scopes: [.repo, .user, .gist]
)

// Open in browser
UIApplication.shared.open(authURL)
```

### GitHub Actions Core

#### Environment Variables

```swift
import Core

// Check if running in GitHub Actions
if Core.env.isRunningInGitHubActions() {
    print("Running in GitHub Actions!")
}

// Get workflow information
let workflow = Core.env.getWorkflow()
let repository = Core.env.getRepository()
let event = Core.env.getEventName()
```

#### Inputs and Outputs

```swift
// Read workflow inputs
let token = try Core.getInput(
    "github-token",
    options: InputOptions(required: true)
)

let verboseMode = Core.getBooleanInput("verbose")

let tags = Core.getMultilineInput("tags")

// Set outputs
Core.setOutput(name: "status", value: "success")
Core.setOutput(name: "result", value: "42")
```

#### Logging and Annotations

```swift
// Informational messages
Core.info(message: "Processing files...")
Core.debug(message: "Debug info: \(someVariable)")

// Annotations
Core.warning(message: "This endpoint is deprecated", file: "main.swift", line: 42)
Core.error(message: "Validation failed", file: "validator.swift")
Core.notice(message: "Found 3 warnings")

// Group output
Core.startGroup(name: "Installing dependencies")
// ... commands ...
Core.endGroup()

// Or with closure
try Core.group(name: "Running Tests") {
    // ... your code here ...
}
```

#### Summaries (Step Summaries)

```swift
// Create a Markdown summary for the workflow
let summary = Core.summary

summary
    .addHeading("Test Results", level: 1)
    .addRaw("Ran **150 tests**", addEOL: true)
    .addSeparator()
    .addHeading("Statistics", level: 2)
    .addList([
        "✅ Passed: 145",
        "❌ Failed: 5",
        "⏭️ Skipped: 0"
    ])
    .addSeparator()
    .addHeading("Code Coverage", level: 2)
    .addTable([
        ["Module", "Coverage"],
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

// Write to summary file
try summary.write()

// Clear summary
try summary.clear()
```

#### State and Secrets

```swift
// Save state between steps
Core.saveState(name: "processedFiles", value: "file1.txt,file2.txt")

// Retrieve state in a later step
if let files = Core.getState(name: "processedFiles") {
    print("Processed files: \(files)")
}

// Mark values as secrets (will be masked in logs)
Core.setSecret("my_secret_token")

// Export environment variables
Core.exportVariable(name: "CUSTOM_VAR", value: "custom_value")

// Add to PATH
Core.addPath("/usr/local/custom/bin")
```

#### Mark as Failed

```swift
// Mark the step as failed
if validationFailed {
    Core.setFailed(message: "Validation failed with 5 errors")
    // This sets exit code to 1
}
```

## Project Structure

```
Sources/
├── HttpClient/          # Base HTTP client
│   ├── GitHub.swift     # Main client
│   ├── AuthorizationType.swift
│   ├── RequestError.swift
│   └── ...
├── Github/              # GitHub API
│   ├── GitHubAPI/       # Endpoints organized by category
│   │   ├── Repositories/
│   │   ├── Pull/
│   │   ├── Issue/
│   │   ├── User/
│   │   ├── Releases/
│   │   └── ...
│   └── Models/          # Data models
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
└── Github-toolkit/      # Main package
    └── Github_toolkit.swift
```

## Available Endpoints

### Repositories
- List, search, create, update repositories
- Collaborators, forks, stargazers
- Tags, branches, contributors
- Topics, languages

### Pull Requests
- List, get, search pull requests
- States and reviews

### Issues
- List, search issues
- Labels, milestones, comments

### Releases
- List releases and assets
- Get specific release

### Users
- User profile
- Followers, following
- User search

### Others
- Discussions
- Notifications
- OAuth
- Licenses
- Gitignore templates
- Search (global)

## Data Models

All models implement `Codable` and use `camelCase` automatically:

- `User`: Complete user profile
- `Repository`: Detailed repository information
- `Pull`: Pull Request with metadata
- `Issue`: Issue with labels, milestone, etc.
- `Release`: Release with assets
- `Branch`, `Tag`, `Collaborator`
- `Discussion`, `Notification`
- And many more...

## Error Handling

```swift
do {
    let repos = try await github.repositories(ownerID: "octocat")
} catch let error as RequestError {
    switch error {
    case .notFound:
        print("User not found")
    case .notAuthorized:
        print("Not authorized - check your token")
    case .validationFailed(let message):
        print("Validation error: \(message)")
    case .unknown(let statusCode):
        print("Unknown error: \(statusCode)")
    }
}
```

### Rate Limiting

GitHub has limits on the number of requests you can make per hour. This SDK includes automatic rate limiting handling:

```swift
// Configure rate limiting with auto-retry
let options = RateLimitOptions(
    autoRetry: true,         // Automatically wait when limit is reached
    maxRetries: 3,           // Maximum number of retries
    throwOnLimit: false,     // Don't throw error, wait and retry
    warningThreshold: 0.8    // Warn when 80% of limit is used
)

let github = GitHub(
    accessToken: "your_token",
    rateLimitOptions: options
)

// Manually check rate limit before a request
try await github.checkRateLimit()

// Get current rate limit information
if let rateLimit = await github.getCurrentRateLimit() {
    print("Remaining: \(rateLimit.remaining)/\(rateLimit.limit)")
    print("Resets at: \(rateLimit.reset)")
    print("Usage: \(rateLimit.usagePercentage)%")
}

// Get complete rate limit status
let status = try await github.getRateLimitStatus()
print("Core API: \(status.resources.core.remaining)/\(status.resources.core.limit)")
print("Search API: \(status.resources.search.remaining)/\(status.resources.search.limit)")
print("GraphQL API: \(status.resources.graphql.remaining)/\(status.resources.graphql.limit)")
```

The SDK automatically:
- Extracts rate limit information from response headers
- Warns when approaching the limit (configurable)
- Can automatically wait and retry when limit is reached
- Throws informative errors with reset time

## Requirements

- Swift 5.8+
- iOS 16.0+ / macOS 12.0+
- Xcode 14.0+

## Dependencies

- [swift-http-types](https://github.com/apple/swift-http-types) - Apple's HTTP types system

## Contributing

Contributions are welcome. Please:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Author

**Asiel Cabrera Gonzalez**

## Creating GitHub Actions with Swift

Want to create your own GitHub Actions using Swift? Check out our comprehensive guide and resources:

- 📖 [**Complete Guide to Creating GitHub Actions with Swift**](GITHUB_ACTIONS_GUIDE.md) *(Spanish)*
- 💡 [Basic Action Template](examples/basic-action/) - Ready to use as a starting point

The guide includes:
- Step-by-step tutorial
- 3 complete examples (basic action, repo stats, PR validator)
- Best practices and patterns
- Testing and debugging strategies
- Publishing to GitHub Marketplace

**Note**: The detailed guide is currently available in Spanish. The code examples and templates are universal and easy to follow regardless of language.

## Acknowledgments

- Based on GitHub REST API v3
- Inspired by [@actions/core](https://github.com/actions/toolkit/tree/main/packages/core) and [@actions/github](https://github.com/actions/toolkit/tree/main/packages/github)

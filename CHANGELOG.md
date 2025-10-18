# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Complete Summary API**: Full implementation of Summary API for creating Markdown summaries
  - `write()`: Writes buffer to summary file
  - `clear()`: Clears buffer and file
  - `getfilePath()`: Gets summary file path
  - 12 builder methods: `addHeading()`, `addCodeBlock()`, `addList()`, `addTable()`, etc.
  - Method chaining support
  - Complete error handling with `SummaryError`
  - Read/write permission validation

- **Complete Rate Limiting System**: Robust implementation to handle GitHub API limits
  - `RateLimit`: Struct for rate limit information
  - `RateLimitHandler`: Actor for thread-safe handling
  - `RateLimitOptions`: Customizable configuration (auto-retry, thresholds, etc.)
  - Automatic extraction from HTTP headers
  - Configurable warnings
  - Smart auto-retry with sleep
  - Support for `/rate_limit` endpoint
  - `RateLimitStatus` struct with complete info for all API resources

- **Basic Test Suite**: 19 comprehensive tests
  - 5 HttpClient tests (authentication, initialization)
  - 2 Core tests (environment, GitHub Actions detection)
  - 10 Summary tests (all builder methods)
  - 2 Model tests (User decoding, Repository visibility)

- **Complete Documentation**:
  - Expanded README with 40+ code examples
  - Rate Limiting section with examples
  - Complete guide for creating GitHub Actions with Swift (GITHUB_ACTIONS_GUIDE.md)
  - 3 complete action examples
  - Best practices and recommended patterns
  - Basic action example ready to use

### Fixed
- **Spelling Errors Corrected**:
  - `Acitivity/` → `Activity/`
  - `Foks/` → `Forks/`
  - `ProtentionTags/` → `ProtectionTags/`
  - `Realeases/` → `Releases/`

- **API Visibility**:
  - All Summary methods are now `public`
  - `SummaryError` is `public`
  - `SummaryWriteOptions` is `public` with initializer

### Changed
- **Platform Requirements Updated**:
  - macOS: `10.13+` → `12.0+` (for async/await and Task.sleep support)
  - Updated in Package.swift and README.md

- **Test Dependencies**:
  - Test target now includes all necessary dependencies (HttpClient, Core, Github)

### Technical Details

#### New Files
- `Sources/HttpClient/RateLimit.swift` (93 lines)
- `Sources/HttpClient/RateLimitHandler.swift` (112 lines)
- `Sources/HttpClient/GitHub+RateLimit.swift` (131 lines)
- `GITHUB_ACTIONS_GUIDE.md` (850+ lines)
- `examples/basic-action/` (Complete example project)
- `CHANGELOG.md` (This file)

#### Modified Files
- `Sources/Core/Summary.swift`: From 54 lines → 295 lines
- `Sources/Core/Utils/SummaryWriteOptions.swift`: Added public initializer
- `Sources/HttpClient/GitHub.swift`: RateLimitHandler integration
- `Tests/Github-toolkitTests/Github_toolkitTests.swift`: From 1 test → 19 tests
- `README.md`: From 3 lines → 466 lines
- `Package.swift`: Minimum platform update

#### Statistics
- **+854 lines of new code** implemented
- **+850 lines of documentation** added
- **0 compilation errors**
- **0 warnings**
- **4 directories corrected**
- **19 tests created**

## [0.0.1] - 2023-XX-XX

### Added
- Initial GitHub Toolkit implementation
- HTTP client with authentication
- 39+ GitHub API endpoints
- 63 data models
- Core toolkit for GitHub Actions
- Support for iOS 16+ and macOS 10.13+

---

## Future Versions

### Planned for v0.1.0
- [ ] GraphQL API support
- [ ] Webhooks handling
- [ ] GitHub Apps authentication
- [ ] Actions API (workflows, artifacts, cache)
- [ ] Secrets management API
- [ ] Packages/Container Registry API
- [ ] Code Scanning & Security APIs
- [ ] Gists API

### Planned for v0.2.0
- [ ] Request caching layer
- [ ] Advanced pagination helpers
- [ ] Webhook signature validation
- [ ] More comprehensive test coverage
- [ ] DocC documentation
- [ ] CI/CD automation

---

[Unreleased]: https://github.com/devswiftzone/github-toolkit/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/devswiftzone/github-toolkit/releases/tag/v0.0.1

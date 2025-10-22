import Testing
import Foundation
@testable import Github_toolkit
@testable import HttpClient
@testable import Core
@testable import Github

// MARK: - HttpClient Tests

@Test("Authorization type with token")
func testAuthorizationTypeWithToken() {
    let token = "ghp_testtoken123"
    let authType = AuthorizationType.bearerToken(accessToken: token)

    switch authType {
    case .bearerToken(let accessToken):
        #expect(accessToken == token)
    case .withoutToken:
        Issue.record("Expected bearerToken, got withoutToken")
    }
}

@Test("Authorization type without token")
func testAuthorizationTypeWithoutToken() {
    let authType = AuthorizationType.withoutToken

    switch authType {
    case .bearerToken:
        Issue.record("Expected withoutToken, got bearerToken")
    case .withoutToken:
        // Success
        break
    }
}

@Test("GitHub client initialization with token")
func testGitHubClientInitialization() {
    let token = "ghp_testtoken123"
    let github = GitHub(accessToken: token)

    // Verify the client was created successfully
    #expect(github != nil)
}

@Test("GitHub client without token")
func testGitHubClientWithoutToken() {
    let github = GitHub(type: .withoutToken)

    // Verify the client was created successfully
    #expect(github != nil)
}

@Test("OrderType values")
func testOrderTypeValues() {
    #expect(OrderType.asc.rawValue == "asc")
    #expect(OrderType.desc.rawValue == "desc")
}

// MARK: - Core Tests

@Test("Environment variables don't crash")
func testEnvironmentVariables() {
    // Test that environment functions don't crash
    _ = Core.Environment.getRunnerVersion()
    _ = Core.Environment.getOS()
    _ = Core.Environment.getArchitecture()
    _ = Core.Environment.isRunningInGitHubActions()
    _ = Core.Environment.getWorkflow()
    _ = Core.Environment.getRepository()
    _ = Core.Environment.getEventName()
    _ = Core.Environment.getEventPath()
    _ = Core.Environment.getGithubEnv()
    _ = Core.Environment.getPath()
}

@Test("Not running in GitHub Actions")
func testIsNotRunningInGitHubActions() {
    // In test environment, we should not be in GitHub Actions
    #expect(Core.env.isRunningInGitHubActions() == false)
}

// MARK: - Summary Tests

@Test("Summary buffer initialization")
func testSummaryBufferInitialization() {
    let summary = Summary()
    #expect(summary.isEmpty())
}

@Test("Summary add raw text")
func testSummaryAddRaw() {
    let summary = Summary()
    summary.addRaw("Test content")
    #expect(!summary.isEmpty())
}

@Test("Summary add heading")
func testSummaryAddHeading() {
    let summary = Summary()
    summary.addHeading("Test Heading", level: 2)
    #expect(!summary.isEmpty())
}

@Test("Summary add code block")
func testSummaryAddCodeBlock() {
    let summary = Summary()
    summary.addCodeBlock("let x = 5", language: "swift")
    #expect(!summary.isEmpty())
}

@Test("Summary add list")
func testSummaryAddList() {
    let summary = Summary()
    summary.addList(["Item 1", "Item 2", "Item 3"])
    #expect(!summary.isEmpty())
}

@Test("Summary add ordered list")
func testSummaryAddOrderedList() {
    let summary = Summary()
    summary.addList(["First", "Second", "Third"], ordered: true)
    #expect(!summary.isEmpty())
}

@Test("Summary add table")
func testSummaryAddTable() {
    let summary = Summary()
    let rows = [
        ["Header 1", "Header 2"],
        ["Cell 1", "Cell 2"],
        ["Cell 3", "Cell 4"]
    ]
    summary.addTable(rows)
    #expect(!summary.isEmpty())
}

@Test("Summary add separator")
func testSummaryAddSeparator() {
    let summary = Summary()
    summary.addSeparator()
    #expect(!summary.isEmpty())
}

@Test("Summary add quote")
func testSummaryAddQuote() {
    let summary = Summary()
    summary.addQuote("This is a quote")
    #expect(!summary.isEmpty())
}

@Test("Summary add link")
func testSummaryAddLink() {
    let summary = Summary()
    summary.addLink("GitHub", url: "https://github.com")
    #expect(!summary.isEmpty())
}

@Test("Summary chaining")
func testSummaryChaining() {
    let summary = Summary()
    summary
        .addHeading("Test Report", level: 1)
        .addRaw("Some content")
        .addSeparator()
        .addList(["Item 1", "Item 2"])

    #expect(!summary.isEmpty())
}

@Test("Summary error when no environment variable")
func testSummaryErrorWhenNoEnvironmentVariable() throws {
    let summary = Summary()
    summary.addRaw("Test content")

    // This should throw because GITHUB_STEP_SUMMARY is not set
    #expect(throws: SummaryError.self) {
        try summary.write()
    }
}

// MARK: - Model Tests

@Test("User model decoding")
func testUserModelDecoding() throws {
    let json = """
    {
        "id": 1,
        "login": "testuser",
        "node_id": "MDQ6VXNlcjE=",
        "avatar_url": "https://github.com/images/error/testuser_happy.gif",
        "gravatar_id": "",
        "url": "https://api.github.com/users/testuser",
        "html_url": "https://github.com/testuser",
        "followers_url": "https://api.github.com/users/testuser/followers",
        "following_url": "https://api.github.com/users/testuser/following{/other_user}",
        "gists_url": "https://api.github.com/users/testuser/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/testuser/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/testuser/subscriptions",
        "organizations_url": "https://api.github.com/users/testuser/orgs",
        "repos_url": "https://api.github.com/users/testuser/repos",
        "events_url": "https://api.github.com/users/testuser/events{/privacy}",
        "received_events_url": "https://api.github.com/users/testuser/received_events",
        "type": "User",
        "site_admin": false
    }
    """

    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()

    let user = try decoder.decode(User.self, from: data)
    #expect(user.id == 1)
    #expect(user.userID == "testuser")
    #expect(user.siteAdmin == false)
}

@Test("Repository visibility")
func testRepositoryVisibility() {
    #expect(Visibility.public.rawValue == "public")
    #expect(Visibility.private.rawValue == "private")
}

// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "BasicAction",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/devswiftzone/github-toolkit.git", from: "0.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "BasicAction",
            dependencies: [
                .product(name: "Core", package: "github-toolkit"),
            ],
            path: "Sources"
        ),
    ]
)

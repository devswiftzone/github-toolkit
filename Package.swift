// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Github-toolkit",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Github-toolkit",
            targets: ["Github-toolkit"]),
        .library(name: "Core", targets: ["Core"]),
        .library(name: "HttpClient", targets: ["HttpClient"]),
        .library(name: "Github", targets: ["Github"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types", .upToNextMajor(from: "0.1.1"))
    ],
    targets: [
        
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
            .target(
                name: "Github-toolkit",
                dependencies: ["Core", "Github"]),
        .target(
            name: "Core",
            dependencies: ["HttpClient"]
        ),
        .target(
            name: "Github",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
                "HttpClient"
            ]
        ),
        .target(
            name: "HttpClient",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
            ]
        ),
        .testTarget(
            name: "Github-toolkitTests",
            dependencies: ["Github-toolkit", "HttpClient", "Core", "Github"]),
    ]
)

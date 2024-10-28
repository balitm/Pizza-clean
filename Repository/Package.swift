// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Repository",
    platforms: [
        .iOS("16"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Repository",
            targets: ["Repository"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../DataSource"),
        .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Repository",
            dependencies: [
                "Domain",
                "DataSource",
                .product(name: "XCStringsToolPlugin", package: "xcstrings-tool-plugin"),
            ],
            swiftSettings: [
                .define("XCSTRINGS_TOOL_ACCESS_LEVEL_PUBLIC"),
            ]
        ),
        .testTarget(
            name: "RepositoryTests",
            dependencies: ["Repository"]
        ),
    ]
)

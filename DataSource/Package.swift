// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataSource",
    platforms: [
        .iOS("16"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataSource",
            targets: ["DataSource"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "10.54.0")),
        .package(url: "https://github.com/hmlongco/Factory.git", exact: .init(stringLiteral: "2.4.5")),
        .package(url: "https://github.com/ashleymills/Reachability.swift", exact: .init(stringLiteral: "5.2.4")),
        .package(path: "../Domain"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataSource",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Factory", package: "Factory"),
                .product(name: "Reachability", package: "Reachability.swift"),
                "Domain",
            ]),
        .testTarget(
            name: "DataSourceTests",
            dependencies: ["DataSource"]
        ),
    ]
)

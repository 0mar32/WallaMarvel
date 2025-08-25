// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkStubsUITestUtils",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NetworkStubsUITestUtils",
            targets: ["NetworkStubsUITestUtils"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
        .package(path: "../AppConfig"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NetworkStubsUITestUtils",
            dependencies: [
                "AppConfig",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),

    ]
)

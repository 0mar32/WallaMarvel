// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkClientConfig",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NetworkClientConfig",
            targets: ["NetworkClientConfig"]),
    ],
     dependencies: [
        // Local dependency on NetworkClient
        .package(path: "../NetworkClient")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NetworkClientConfig",
            dependencies: [
                "NetworkClient" // This is the *product name* from NetworkClient’s Package.swift
            ]
        ),
        .testTarget(
            name: "NetworkClientConfigTests",
            dependencies: ["NetworkClientConfig"]
        ),
    ]
)

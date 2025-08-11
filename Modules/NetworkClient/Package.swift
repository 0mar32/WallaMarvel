// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkClient",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "NetworkClient",
            targets: ["NetworkClient"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkClient",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient"]
        ),
    ]
)

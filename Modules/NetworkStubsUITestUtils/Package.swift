// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkStubsUITestUtils",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "NetworkStubsUITestUtils", targets: ["NetworkStubsUITestUtils"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"),
        .package(path: "../AppConfig")
    ],
    targets: [
        .target(
            name: "NetworkStubsUITestUtils",
            dependencies: [
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                "AppConfig"
            ],
            resources: [
                // Put your fixtures here: Resources/heroes_page_0.json, Resources/heroes_page_1.json
                .process("Resources")
            ],
            swiftSettings: [
                // Xcode also defines DEBUG for Debug config, this just makes it explicit for SPM builds
                .define("DEBUG", .when(configuration: .debug))
            ]
        )
    ]
)

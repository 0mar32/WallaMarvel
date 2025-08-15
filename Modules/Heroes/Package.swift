// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Heroes",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Heroes",
            targets: ["Heroes"]),
    ],
    dependencies: [
       // Local dependency on NetworkClient
       .package(path: "../HeroesCore")
   ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Heroes",
            dependencies: ["HeroesCore"]
        ),
        .testTarget(
            name: "HeroesTests",
            dependencies: ["Heroes"]
        ),
    ]
)

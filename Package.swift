 // swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdvancedCollectionTableView",
    platforms: [
        .macOS("12.0")
    ],
    products: [
        .library(
            name: "AdvancedCollectionTableView",
            targets: ["AdvancedCollectionTableView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/flocked/FZExtensions.git", branch: "main"),
        .package(url: "https://github.com/steipete/InterposeKit.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "AdvancedCollectionTableView",
            dependencies: ["FZExtensions", "InterposeKit", "AdvancedCollectionTableViewObjC"]),
        .target(name: "AdvancedCollectionTableViewObjC", dependencies: [])
    ]
)

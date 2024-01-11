// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdvancedCollectionTableView",
    platforms: [
        .macOS("12.0"),
    ],
    products: [
        .library(
            name: "AdvancedCollectionTableView",
            targets: ["AdvancedCollectionTableView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/flocked/FZSwiftUtils.git", branch: "main"),
        .package(url: "https://github.com/flocked/FZUIKit.git", branch: "main"),
        .package(url: "https://github.com/flocked/FZQuicklook.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "AdvancedCollectionTableView",
            dependencies: ["FZSwiftUtils", "FZUIKit", "FZQuicklook"], path: "Sources/AdvancedCollectionTableView"
        ),
    ]
)

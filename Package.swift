// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OversizeModules",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "OversizeLauncher", targets: ["OversizeLauncher"]),
        .library(name: "OversizeModules", targets: ["OversizeModules"]),
        .library(name: "OversizePINCode", targets: ["OversizePINCode"]),
        .library(name: "OversizeStore", targets: ["OversizeStore"]),
        .library(name: "OversizeSettings", targets: ["OversizeSettings"]),
    ],
    dependencies: [
        .package(name: "OversizeUI", path: "../OversizeUI"),
        .package(name: "OversizeServices", path: "../OversizeServices"),
        .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
        .package(name: "OversizeCore", path: "../OversizeCore"),
        .package(name: "OversizeComponents", path: "../OversizeComponents"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.2"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSVGCoder.git", from: "1.6.1"),
    ],
    targets: [
        .target(
            name: "OversizeLauncher",
            dependencies: [
                "OversizePINCode",
                "OversizeModules",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeSecurityService", package: "OversizeServices"),
                .product(name: "OversizeSettingsService", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "SDWebImageSVGCoder", package: "SDWebImageSVGCoder"),
            ]
        ),
        .target(
            name: "OversizeModules",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeSecurityService", package: "OversizeServices"),
                .product(name: "OversizeSettingsService", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
            ]
        ),
        .target(
            name: "OversizePINCode",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeSecurityService", package: "OversizeServices"),
            ]
        ),
        .target(
            name: "OversizeStore",
            dependencies: [
                "OversizeModules",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeComponents", package: "OversizeComponents"),
            ]
        ),
        .target(
            name: "OversizeSettings",
            dependencies: [
                "OversizeStore",
                "OversizeModules",
                "OversizePINCode",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeSecurityService", package: "OversizeServices"),
                .product(name: "OversizeSettingsService", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
            ]
        ),
        .testTarget(
            name: "OversizeModulesTests",
            dependencies: ["OversizeModules"]
        ),
    ]
)

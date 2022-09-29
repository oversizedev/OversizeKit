// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OversizeKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "OversizeLauncherKit", targets: ["OversizeLauncherKit"]),
        .library(name: "OversizeKit", targets: ["OversizeKit"]),
        .library(name: "OversizeLockscreenKit", targets: ["OversizeLockscreenKit"]),
        .library(name: "OversizeStoreKit", targets: ["OversizeStoreKit"]),
        .library(name: "OversizeSettingsKit", targets: ["OversizeSettingsKit"]),
        .library(name: "OversizeOnboardingKit", targets: ["OversizeOnboardingKit"]),
        .library(name: "OversizeNoticeKit", targets: ["OversizeNoticeKit"]),
    ],
    dependencies: [
        .package(name: "OversizeUI", path: "../OversizeUI"),
        .package(name: "OversizeServices", path: "../OversizeServices"),
        .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
        .package(name: "OversizeCore", path: "../OversizeCore"),
        .package(name: "OversizeComponents", path: "../OversizeComponents"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.2"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSVGCoder.git", from: "1.6.1"),
        .package(name: "OversizeResources", path: "../OversizeResources"),
    ],
    targets: [
        .target(
            name: "OversizeLauncherKit",
            dependencies: [
                "OversizeLockscreenKit",
                "OversizeKit",
                "OversizeStoreKit",
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
            name: "OversizeKit",
            dependencies: [
                "OversizeLockscreenKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeSecurityService", package: "OversizeServices"),
                .product(name: "OversizeSettingsService", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeCore", package: "OversizeCore"),
            ]
        ),
        .target(
            name: "OversizeLockscreenKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeSecurityService", package: "OversizeServices"),
                .product(name: "OversizeCore", package: "OversizeCore"),
            ]
        ),
        .target(
            name: "OversizeStoreKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeComponents", package: "OversizeComponents"),
                .product(name: "OversizeResources", package: "OversizeResources"),
                .product(name: "OversizeCore", package: "OversizeCore"),
            ]
        ),
        .target(
            name: "OversizeOnboardingKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeComponents", package: "OversizeComponents"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeResources", package: "OversizeResources"),
            ]
        ),
        .target(
            name: "OversizeSettingsKit",
            dependencies: [
                "OversizeStoreKit",
                "OversizeKit",
                "OversizeLockscreenKit",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeSecurityService", package: "OversizeServices"),
                .product(name: "OversizeSettingsService", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "OversizeResources", package: "OversizeResources"),
            ]
        ),
        .target(
            name: "OversizeNoticeKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeResources", package: "OversizeResources"),
            ]
        ),
        .testTarget(
            name: "OversizeKitTests",
            dependencies: ["OversizeKit"]
        ),
    ]
)

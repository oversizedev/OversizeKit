// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let remoteDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/oversizedev/OversizeUI.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeComponents.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/oversizedev/OversizeResources.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/oversizedev/OversizeNetwork.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/oversizedev/OversizeModels.git", .upToNextMajor(from: "0.1.0")),
    .package(url: "https://github.com/oversizedev/OversizeRouter.git", .upToNextMajor(from: "0.1.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
    .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image.git", .upToNextMajor(from: "2.1.1")),
    .package(url: "https://github.com/hmlongco/Navigator.git", .upToNextMajor(from: "1.0.0")),
]

let localDependencies: [PackageDescription.Package.Dependency] = [
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(name: "OversizeServices", path: "../OversizeServices"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeComponents", path: "../OversizeComponents"),
    .package(name: "OversizeResources", path: "../OversizeResources"),
    .package(name: "OversizeNetwork", path: "../OversizeNetwork"),
    .package(name: "OversizeModels", path: "../OversizeModels"),
    .package(name: "OversizeRouter", path: "../OversizeRouter"),
    .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image.git", .upToNextMajor(from: "2.1.1")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
    .package(url: "https://github.com/hmlongco/Navigator.git", .upToNextMajor(from: "1.0.0")),
]

let dependencies: [PackageDescription.Package.Dependency] = remoteDependencies

let package = Package(
    name: "OversizeKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(name: "OversizeKit", targets: ["OversizeKit"]),
        .library(name: "OversizeOnboardingKit", targets: ["OversizeOnboardingKit"]),
        .library(name: "OversizeNoticeKit", targets: ["OversizeNoticeKit"]),
        .library(name: "OversizeCalendarKit", targets: ["OversizeCalendarKit"]),
        .library(name: "OversizeContactsKit", targets: ["OversizeContactsKit"]),
        .library(name: "OversizeLocationKit", targets: ["OversizeLocationKit"]),
        .library(name: "OversizeNotificationKit", targets: ["OversizeNotificationKit"]),
        .library(name: "OversizePhotoKit", targets: ["OversizePhotoKit"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeComponents", package: "OversizeComponents"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "OversizeResources", package: "OversizeResources"),
                .product(name: "OversizeNotificationService", package: "OversizeServices"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "OversizeNetwork", package: "OversizeNetwork"),
                .product(name: "OversizeRouter", package: "OversizeRouter"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
                .product(name: "NavigatorUI", package: "Navigator"),
            ]
        ),
        .target(
            name: "OversizeCalendarKit",
            dependencies: [
                "OversizeContactsKit",
                "OversizeLocationKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeCalendarService", package: "OversizeServices"),
                .product(name: "OversizeLocationService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeModels", package: "OversizeModels"),
            ]
        ),
        .target(
            name: "OversizeContactsKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeContactsService", package: "OversizeServices"),
                .product(name: "OversizeCalendarService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeModels", package: "OversizeModels"),
            ]
        ),
        .target(
            name: "OversizeLocationKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeLocationService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeModels", package: "OversizeModels"),
            ]
        ),
        .target(
            name: "OversizeNoticeKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeOnboardingKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
            ]
        ),
        .target(
            name: "OversizeNotificationKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "OversizeNotificationService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizePhotoKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizePhotoComponents", package: "OversizeComponents"),
            ]
        ),
        .testTarget(
            name: "OversizeKitTests",
            dependencies: ["OversizeKit"]
        ),
    ]
)

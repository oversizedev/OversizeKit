// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let productionDependencies: [PackageDescription.Package.Dependency] = { [
    .package(url: "https://github.com/oversizedev/OversizeUI.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeComponents.git", .upToNextMajor(from: "1.2.0")),
    .package(url: "https://github.com/oversizedev/OversizeResources.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
//    .package(name: "OversizeNetwork", path: "../OversizeNetwork"),
//    .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "0.1.0")),
//    .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "0.1.0")),
    // .package(url: "https://github.com/oversizedev/OversizeNetwork.git", .upToNextMajor(from: "0.1.0"))
] }()

let developmentDependencies: [PackageDescription.Package.Dependency] = { [
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(name: "OversizeServices", path: "../OversizeServices"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeComponents", path: "../OversizeComponents"),
    .package(name: "OversizeResources", path: "../OversizeResources"),
    .package(name: "OversizeNetwork", path: "../OversizeNetwork"),
//    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
//    .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "0.1.0")),
//    .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "0.1.0")),
] }()

let package = Package(
    name: "OversizeKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "OversizeKit", targets: ["OversizeKit"]),
        .library(name: "OversizeAdsKit", targets: ["OversizeAdsKit"]),
        .library(name: "OversizeOnboardingKit", targets: ["OversizeOnboardingKit"]),
        .library(name: "OversizeNoticeKit", targets: ["OversizeNoticeKit"]),
        .library(name: "OversizeCalendarKit", targets: ["OversizeCalendarKit"]),
        .library(name: "OversizeContactsKit", targets: ["OversizeContactsKit"]),
        .library(name: "OversizeLocationKit", targets: ["OversizeLocationKit"]),
        .library(name: "OversizeNotificationKit", targets: ["OversizeNotificationKit"]),
        .library(name: "OversizePhotoKit", targets: ["OversizePhotoKit"]),
    ],
    dependencies: productionDependencies,
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
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeAdsKit",
            dependencies: [
                "OversizeKit",
                .product(name: "Factory", package: "Factory"),
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
//                .product(name: "OversizeNetwork", package: "OversizeNetwork"),
//                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
//                .product(
//                    name: "OpenAPIURLSession",
//                    package: "swift-openapi-urlsession"
//                ),
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
                .product(name: "Factory", package: "Factory"),
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
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeLocationKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeLocationService", package: "OversizeServices"),
                .product(name: "Factory", package: "Factory"),
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
                .product(name: "Factory", package: "Factory"),
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
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeNotificationService", package: "OversizeServices"),
                .product(name: "Factory", package: "Factory"),
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

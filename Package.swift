// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let productionDependencies: [PackageDescription.Package.Dependency] = { [
    .package(url: "https://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@github.com/oversizedev/OversizeUI.git", branch: "main"),
    .package(url: "https://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@github.com/oversizedev/OversizeServices.git", branch: "main"),
    .package(url: "https://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@github.com/oversizedev/OversizeLocalizable.git", branch: "main"),
    .package(url: "https://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@github.com/oversizedev/OversizeCore.git", branch: "main"),
    .package(url: "https://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@github.com/oversizedev/OversizeComponents.git", branch: "main"),
    .package(url: "https://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@github.com/oversizedev/OversizeResources.git", branch: "main"),
    //.package(url: "https://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@github.com/oversizedev/OversizeCDN.git", branch: "main"),
    //.package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.2"),
    //.package(url: "https://github.com/SDWebImage/SDWebImageSVGCoder.git", from: "1.6.1"),
] }()

let developmentDependencies: [PackageDescription.Package.Dependency] = { [
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(name: "OversizeServices", path: "../OversizeServices"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeComponents", path: "../OversizeComponents"),
    .package(name: "OversizeResources", path: "../OversizeResources"),
    //.package(name: "OversizeCDN", path: "../OversizeCDN"),
    //.package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.2"),
    //.package(url: "https://github.com/SDWebImage/SDWebImageSVGCoder.git", from: "1.6.1"),
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
                //.product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                //.product(name: "SDWebImageSVGCoder", package: "SDWebImageSVGCoder"),
                //.product(name: "OversizeCDN", package: "OversizeCDN"),
            ]
        ),
        .target(
            name: "OversizeAdsKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
            ]
        ),
        .target(
            name: "OversizeCalendarKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeCalendarService", package: "OversizeServices"),
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
            ]
        ),
        .target(
            name: "OversizeLocationKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeLocationService", package: "OversizeServices"),
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
            ]
        ),
        .target(
            name: "OversizeOnboardingKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
            ]
        ),
        .testTarget(
            name: "OversizeKitTests",
            dependencies: ["OversizeKit"]
        ),
    ]
)

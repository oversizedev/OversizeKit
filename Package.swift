// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let commonDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/hmlongco/Navigator.git", .upToNextMajor(from: "2.0.2")),
]

let remoteDependencies: [PackageDescription.Package.Dependency] = commonDependencies + [
    .package(url: "https://github.com/oversizedev/OversizeUI.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.5.0")),
    .package(url: "https://github.com/oversizedev/OversizeComponents.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/oversizedev/OversizeResources.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/oversizedev/OversizeNetwork.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/oversizedev/OversizeNavigation.git", .upToNextMajor(from: "0.7.0")),
    .package(url: "https://github.com/oversizedev/OversizeArchitecture.git", .upToNextMajor(from: "0.2.0")),
    .package(url: "https://github.com/oversizedev/OversizeIntelligenceService.git", .upToNextMajor(from: "0.1.0")),
]

let localDependencies: [PackageDescription.Package.Dependency] = commonDependencies + [
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(name: "OversizeServices", path: "../OversizeServices"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeComponents", path: "../OversizeComponents"),
    .package(name: "OversizeResources", path: "../OversizeResources"),
    .package(name: "OversizeNetwork", path: "../OversizeNetwork"),
    .package(name: "OversizeNavigation", path: "../OversizeNavigation"),
    .package(name: "OversizeArchitecture", path: "../OversizeArchitecture"),
    .package(name: "OversizeIntelligenceService", path: "../OversizeIntelligenceService"),
]

let isLocalDev = FileManager.default.fileExists(atPath: "\(NSHomeDirectory())/Developer/Packages/OversizeCore")
let dependencies: [PackageDescription.Package.Dependency] = isLocalDev ? localDependencies : remoteDependencies

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
        .library(name: "OversizeEditorKit", targets: ["OversizeEditorKit"]),
        .library(name: "OversizeOnboardingKit", targets: ["OversizeOnboardingKit"]),
        .library(name: "OversizeNoticeKit", targets: ["OversizeNoticeKit"]),
        .library(name: "OversizeCalendarKit", targets: ["OversizeCalendarKit"]),
        .library(name: "OversizeContactsKit", targets: ["OversizeContactsKit"]),
        .library(name: "OversizeLocationKit", targets: ["OversizeLocationKit"]),
        .library(name: "OversizeNotificationKit", targets: ["OversizeNotificationKit"]),
        .library(name: "OversizeMediaKit", targets: ["OversizeMediaKit"]),
        .library(name: "OversizeCloudKit", targets: ["OversizeCloudKit"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeWebService", package: "OversizeServices"),
                .product(name: "OversizeNotificationService", package: "OversizeServices"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeComponents", package: "OversizeComponents"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "OversizeResources", package: "OversizeResources"),
                .product(name: "OversizeNetwork", package: "OversizeNetwork"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "NavigatorUI", package: "Navigator"),
                .product(name: "OversizeNavigation", package: "OversizeNavigation"),
                .product(name: "OversizeArchitecture", package: "OversizeArchitecture"),
            ]
        ),
        .target(
            name: "OversizeCalendarKit",
            dependencies: [
                "OversizeContactsKit",
                "OversizeLocationKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeResources", package: "OversizeResources"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeCalendarService", package: "OversizeServices"),
                .product(name: "OversizeLocationService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeCore", package: "OversizeCore"),
            ]
        ),
        .target(
            name: "OversizeContactsKit",
            dependencies: [
                // "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeContactsService", package: "OversizeServices"),
                .product(name: "OversizeCalendarService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeCore", package: "OversizeCore"),
            ]
        ),
        .target(
            name: "OversizeLocationKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeLocationService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeCore", package: "OversizeCore"),
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
                .product(name: "NavigatorUI", package: "Navigator"),
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
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeNotificationService", package: "OversizeServices"),
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeMediaKit",
            dependencies: [
                "OversizeKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeResources", package: "OversizeResources"),
            ]
        ),
        .target(
            name: "OversizeEditorKit",
            dependencies: [
                "OversizeKit",
                "OversizeMediaKit",
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeResources", package: "OversizeResources"),
                .product(name: "OversizeIntelligenceService", package: "OversizeIntelligenceService"),
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeCloudKit",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeCloudService", package: "OversizeServices"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeResources", package: "OversizeResources"),
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
        .testTarget(
            name: "OversizeKitTests",
            dependencies: [
                "OversizeKit",
                .product(name: "NavigatorUI", package: "Navigator"),
            ]
        ),
        .testTarget(
            name: "OversizeNotificationKitTests",
            dependencies: ["OversizeNotificationKit"]
        ),
    ]
)

// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PersistedValue",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "PersistedValue",
            targets: ["PersistedValue"]),
        .library(
            name: "PersistedValueTestingUtilities",
            targets: ["PersistedValueTestingUtilities"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PersistedValue",
            dependencies: []),
        .target(
            name: "PersistedValueTestingUtilities",
            dependencies: ["PersistedValue"]),
        .testTarget(
            name: "PersistedValueTests",
            dependencies: ["PersistedValue", "PersistedValueTestingUtilities"]),
        .testTarget(
            name: "PersistedValueTestingUtilitiesTests",
            dependencies: ["PersistedValue", "PersistedValueTestingUtilities"]),
    ]
)

// swift-tools-version: 6.2
// Package manifest for the OpenHoof macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "OpenHoof",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "OpenHoofIPC", targets: ["OpenHoofIPC"]),
        .library(name: "OpenHoofDiscovery", targets: ["OpenHoofDiscovery"]),
        .executable(name: "OpenHoof", targets: ["OpenHoof"]),
        .executable(name: "openhoof-mac", targets: ["OpenHoofMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/OpenHoofKit"),
        .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "OpenHoofIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "OpenHoofDiscovery",
            dependencies: [
                .product(name: "OpenHoofKit", package: "OpenHoofKit"),
            ],
            path: "Sources/OpenHoofDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "OpenHoof",
            dependencies: [
                "OpenHoofIPC",
                "OpenHoofDiscovery",
                .product(name: "OpenHoofKit", package: "OpenHoofKit"),
                .product(name: "OpenHoofChatUI", package: "OpenHoofKit"),
                .product(name: "OpenHoofProtocol", package: "OpenHoofKit"),
                .product(name: "SwabbleKit", package: "swabble"),
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
            ],
            exclude: [
                "Resources/Info.plist",
            ],
            resources: [
                .copy("Resources/OpenHoof.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "OpenHoofMacCLI",
            dependencies: [
                "OpenHoofDiscovery",
                .product(name: "OpenHoofKit", package: "OpenHoofKit"),
                .product(name: "OpenHoofProtocol", package: "OpenHoofKit"),
            ],
            path: "Sources/OpenHoofMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "OpenHoofIPCTests",
            dependencies: [
                "OpenHoofIPC",
                "OpenHoof",
                "OpenHoofDiscovery",
                .product(name: "OpenHoofProtocol", package: "OpenHoofKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])

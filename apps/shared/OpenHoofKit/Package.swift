// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "OpenHoofKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "OpenHoofProtocol", targets: ["OpenHoofProtocol"]),
        .library(name: "OpenHoofKit", targets: ["OpenHoofKit"]),
        .library(name: "OpenHoofChatUI", targets: ["OpenHoofChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.0"),
        .package(url: "https://github.com/gonzalezreal/textual", exact: "0.3.1"),
    ],
    targets: [
        .target(
            name: "OpenHoofProtocol",
            path: "Sources/OpenHoofProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "OpenHoofKit",
            dependencies: [
                "OpenHoofProtocol",
                .product(name: "ElevenLabsKit", package: "ElevenLabsKit"),
            ],
            path: "Sources/OpenHoofKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "OpenHoofChatUI",
            dependencies: [
                "OpenHoofKit",
                .product(
                    name: "Textual",
                    package: "textual",
                    condition: .when(platforms: [.macOS, .iOS])),
            ],
            path: "Sources/OpenHoofChatUI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "OpenHoofKitTests",
            dependencies: ["OpenHoofKit", "OpenHoofChatUI"],
            path: "Tests/OpenHoofKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])

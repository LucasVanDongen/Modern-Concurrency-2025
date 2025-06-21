// swift-tools-version: 6.2

// DEFAULT ISOLATION, AVAILABLE FROM SWIFT 6.2
// WAIT UNTIL XCODE 17 BETAS to build 6.2 packages from Xcode

import PackageDescription

let package = Package(
    name: "DefaultIsolation",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "DefaultIsolation",
            targets: ["DefaultIsolation"]
        ),
    ],
    targets: [
        .target(
            name: "DefaultIsolation",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "DefaultIsolationTests",
            dependencies: ["DefaultIsolation"]
        ),
    ]
)

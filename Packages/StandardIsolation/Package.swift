// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "StandardIsolation",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StandardIsolation",
            targets: ["StandardIsolation"]),
    ],
    targets: [
        .target(
            name: "StandardIsolation",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "StandardIsolationTests",
            dependencies: ["StandardIsolation"]
        ),
    ]
)

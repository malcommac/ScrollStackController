// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "ScrollStackController",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "ScrollStackController",
            targets: ["ScrollStackController"]
        ),
    ],
    targets: [
        .target(
            name: "ScrollStackController",
            dependencies: []
        ),
    ]
)

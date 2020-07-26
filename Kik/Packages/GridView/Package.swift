// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GridView",
    platforms: [
//         .macOS(.v10_10),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v3)
    ],

    products: [
        .library(
            name: "GridView",
            type: .dynamic,
            targets: ["GridView"]),
    ],

    dependencies: [
        .package(
            name: "Prelude",
            url:  "https://github.com/pointfreeco/swift-prelude.git",
            .branch("main")
        ),

        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.8.1"
        ),
    ],

    targets: [
        .target(
            name: "GridView",
            dependencies: [
                .product(name: "Either", package: "Prelude"),
            ]
        ),
        .testTarget(
            name: "GridViewTests",
            dependencies: [
                "GridView",
                "SnapshotTesting",
            ],
            exclude: [
                "__Snapshots__",
            ]
        )
    ]
)

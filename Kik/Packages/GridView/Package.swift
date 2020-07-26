// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GridView",
    platforms: [
//         .macOS(.v10_10),
        .iOS(.v12),
        .tvOS(.v12),
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

        .package(
            name: "OptionalAPI",
            url:  "https://github.com/sloik/OptionalAPI.git",
            .branch("master")
        ),

//      .package(
//        name: "Runes",
//        url: "https://github.com/thoughtbot/Runes",
//        from: "5.0.0"
//        ),
    ],

    targets: [
        .target(
            name: "GridView",
            dependencies: [
                .product(name: "Either", package: "Prelude"),
                "OptionalAPI",
//                "Runes"
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

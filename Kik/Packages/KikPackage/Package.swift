// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KikPackage",

    platforms: [
        .macOS(.v10_10),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v3)
    ],

    products: [
        .library(
            name: "KikDomain",
            type: .dynamic,
            targets: ["KikDomain"]),

        .library(
            name: "KikImplementation",
            type: .dynamic,
            targets: ["KikImplementation"]),

        
        .library(
            name: "GridView",
            type: .dynamic,
            targets: ["GridView"]),


        .library(
            name: "KikApplication",
            type: .dynamic,
            targets: ["KikApplication"]),
    ],

    dependencies: [

        .package(
            name: "Prelude",
            url: "https://github.com/pointfreeco/swift-prelude.git",
            .branch("main")
        ),

        .package(
            name: "Overture",
            url: "https://github.com/pointfreeco/swift-overture.git",
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

        .package(
            name: "FunctionalAPI",
            url:  "https://github.com/sloik/FunctionalAPI.git",
            .branch("master")
        ),
    ],
    
    
    targets: [
        .target(
            name: "KikDomain",
            dependencies: []),


        .target(
            name: "KikImplementation",
            dependencies: [
                "KikDomain",
                "Prelude",
                "OptionalAPI",
                "Overture",
                "FunctionalAPI",
            ]),
        .testTarget(
            name: "KikImplementationTests",
            dependencies: [
                "KikImplementation",
                "SnapshotTesting",
                "FunctionalAPI",
            ],
            exclude: [
                "__Snapshots__",
            ]
        ),
        


        .target(
            name: "GridView",
            dependencies: [
                .product(name: "Either", package: "Prelude"),
                "OptionalAPI",
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
        ),


        .target(
            name: "KikApplication",
            dependencies: [
                "GridView",
                "KikImplementation",
                "Overture",
            ]
        ),


    ]
)

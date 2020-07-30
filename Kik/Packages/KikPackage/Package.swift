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
            name: "KikPackage",
            type: .dynamic,
            targets: ["KikPackage"]),

        .library(
            name: "KikDomain",
            type: .dynamic,
            targets: ["KikDomain"]),

        .library(
            name: "KikImplementation",
            type: .dynamic,
            targets: ["KikImplementation"]),
    ],

    dependencies: [

    ],
    
    targets: [
        .target(
            name: "KikPackage",
            dependencies: []),
        .testTarget(
            name: "KikPackageTests",
            dependencies: ["KikPackage"]),

        .target(
            name: "KikDomain",
            dependencies: []),
//        .testTarget(
//            name: "KikDomainTests",
//            dependencies: ["KikDomain"]),

        .target(
            name: "KikImplementation",
            dependencies: []),

    ]
)

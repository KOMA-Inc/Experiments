// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Experiments",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Experiments",
            targets: ["Experiments"]
        ),
        .library(
            name: "FirebaseExperiments",
            targets: ["FirebaseExperiments"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            from: "10.16.0"
        )
    ],
    targets: [
        .target(name: "Experiments"),
        .target(
            name: "FirebaseExperiments",
            dependencies: [
                "Experiments",
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
            ]
        )
    ]
)

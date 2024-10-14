// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Experiments",
    platforms: [
        .macOS(.v10_15),
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
            from: "11.3.0"
        ),
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0"
        )
    ],
    targets: [
        .target(
            name: "Experiments",
            dependencies: [
                "ExperimentsMacros"
            ]
        ),
        .target(
            name: "FirebaseExperiments",
            dependencies: [
                "Experiments",
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
            ]
        ),
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "ExperimentsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "MacrosClient",
            dependencies: ["Experiments"]
        ),
        .testTarget(
            name: "MacrosTests",
            dependencies: [
                "ExperimentsMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
        .testTarget(name: "ExperimentsTests", dependencies: ["Experiments"])
    ]
)

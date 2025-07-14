// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyMacOSAppFeature",
    platforms: [.macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MyMacOSAppFeature",
            targets: ["MyMacOSAppFeature"]
        ),
        .library(
            name: "MyMacOSAppUIComponents",
            targets: ["MyMacOSAppUIComponents"]
        ),
        .library(
            name: "MyMacOSAppServices",
            targets: ["MyMacOSAppServices"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/containerization", from: "0.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MyMacOSAppUIComponents"
        ),
        .target(
            name: "MyMacOSAppServices",
            dependencies: [
                .product(name: "Containerization", package: "containerization")
            ]
        ),
        .target(
            name: "MyMacOSAppFeature",
            dependencies: [
                "MyMacOSAppUIComponents",
                "MyMacOSAppServices"
            ]
        ),
        .testTarget(
            name: "MyMacOSAppFeatureTests",
            dependencies: ["MyMacOSAppFeature"]
        ),
        .testTarget(
            name: "MyMacOSAppUIComponentsTests",
            dependencies: ["MyMacOSAppUIComponents"]
        ),
        .testTarget(
            name: "MyMacOSAppServicesTests",
            dependencies: ["MyMacOSAppServices"]
        ),
    ]
)

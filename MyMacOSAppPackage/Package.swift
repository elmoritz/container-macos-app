// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyMacOSAppFeature",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MyMacOSAppFeature",
            targets: ["Features"]
        ),
//        .library(
//            name: "MyMacOSAppUIComponents",
//            targets: ["UIComponents"]
//        ),
//        .library(
//            name: "MyMacOSAppServices",
//            targets: ["Services"]
//        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Features",
            dependencies: [
                "UIComponents",
                "Services",
                "GameEngine"
            ]
        ),
        .target(
            name: "UIComponents",
            dependencies: [
                "GameEngine"
            ]
        ),
        .target(
            name: "Services",
            dependencies: [
                "GameEngine"
            ]
        ),
        .target(
            name: "GameEngine"
        ),
        .testTarget(
            name: "MyMacOSAppFeatureTests",
            dependencies: ["Features"]
        ),
        .testTarget(
            name: "MyMacOSAppUIComponentsTests",
            dependencies: ["UIComponents"]
        ),
        .testTarget(
            name: "MyMacOSAppServicesTests",
            dependencies: ["Services"]
        ),
    ]
)

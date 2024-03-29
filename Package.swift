// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarJoin",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "StarJoin",
            targets: [
                "StarJoinSelector",
                "StarJoinSpriteKitAdaptor",
                "StarJoinSceneKitAdaptor",
                "StarJoinNSViewAdaptor",
                "StarJoinUIViewAdaptor"
            ]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "StarJoinSelector"
        ),
        .testTarget(
            name: "StarJoinSelectorTests",
            dependencies: ["StarJoinSelector"]),
        .target(
            name: "StarJoinSpriteKitAdaptor",
            dependencies: ["StarJoinSelector"],
            path: "Sources/Adaptors/SpriteKit"
        ),
        .testTarget(
            name: "StarJoinSpriteKitAdaptorTests",
            dependencies: [
                "StarJoinSpriteKitAdaptor", "StarJoinSelector"
            ]
        ),
        .target(
            name: "StarJoinSceneKitAdaptor",
            dependencies: ["StarJoinSelector"],
            path: "Sources/Adaptors/SceneKit"
        ),
        .testTarget(
            name: "StarJoinSceneKitAdaptorTests",
            dependencies: [
                "StarJoinSelector", "StarJoinSceneKitAdaptor"
            ]
        ),
        .target( // Mac Only
            name: "StarJoinNSViewAdaptor",
            dependencies: ["StarJoinSelector"],
            path: "Sources/Adaptors/NSView"
        ),
        .testTarget(
            name: "StarJoinNSViewAdaptorTests",
            dependencies: ["StarJoinNSViewAdaptor", "StarJoinSelector"]
        ),
        .target(
            name: "StarJoinUIViewAdaptor",
            dependencies: ["StarJoinSelector"],
            path: "Sources/Adaptors/UIView"
        ),
        .testTarget(
            name: "StarJoinUIViewAdaptorTests",
            dependencies: ["StarJoinSelector", "StarJoinUIViewAdaptor"]
        )
    ]
)

// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AwesomeAnimation",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AwesomeAnimation",
            targets: ["AwesomeAnimation"]
        ),
    ],
    targets: [
        .target(
            name: "AwesomeAnimation",
            dependencies: ["Shared"]
        ),
        .target(name: "Shared", publicHeadersPath: "."),
        .testTarget(
            name: "AwesomeAnimationTests",
            dependencies: ["AwesomeAnimation"]
        )
    ]
)

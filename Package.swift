// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Something",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Something",
            targets: ["Something"]
        ),
    ],
    targets: [
        .target(
            name: "Something",
            dependencies: ["Shared"]
        ),
        .target(name: "Shared", publicHeadersPath: "."),
        .testTarget(
            name: "SomethingTests",
            dependencies: ["Something"]
        )
    ]
)

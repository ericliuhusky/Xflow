// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Flow",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "Flow",
            targets: ["Flow"]),
//        .executable(name: "Flow", targets: ["Flow"])
    ],
    dependencies: [
        .package(url: "https://github.com/ericliuhusky/Regex.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Flow",
            dependencies: ["Regex"]),
        .testTarget(
            name: "FlowTests",
            dependencies: ["Flow"]),
    ]
)

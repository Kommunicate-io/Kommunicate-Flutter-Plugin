// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "kommunicate_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "kommunicate-flutter", targets: ["kommunicate_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/Kommunicate-io/Kommunicate-iOS-SDK.git", exact: "7.3.8")
    ],
    targets: [
        .target(
            name: "kommunicate_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Kommunicate", package: "Kommunicate-iOS-SDK")
            ]
        )
    ]
)

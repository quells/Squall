// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Squall",
    products: [
        .library(name: "Squall", targets: ["Squall"])
    ],
    targets: [
        .target(name: "Squall", path: "Sources")
    ]
)

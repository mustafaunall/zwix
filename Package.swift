// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Zwix",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "Zwix", path: "Sources/Zwix", exclude: ["Resources"])
    ]
)

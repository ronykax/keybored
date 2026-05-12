// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "tapsh",
    targets: [
        .executableTarget(
            name: "tapsh",
            path: ".",
            exclude: ["config.json", "README.md"]
        )
    ]
)

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Elsewhere",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "ElsewhereCore", targets: ["ElsewhereCore"])
    ],
    targets: [
        .target(
            name: "ElsewhereCore",
            path: "Sources/ElsewhereCore"
        ),
        .executableTarget(
            name: "Elsewhere",
            dependencies: ["ElsewhereCore"],
            path: "Sources/Elsewhere"
        ),
        .testTarget(
            name: "ElsewhereTests",
            dependencies: ["ElsewhereCore"],
            path: "Tests/ElsewhereTests"
        )
    ]
)

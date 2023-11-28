// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "URLSchemer",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "URLSchemer",
            targets: ["URLSchemer"]),
    ],
    targets: [
        .target(
            name: "URLSchemer"),
        .testTarget(
            name: "URLSchemerTests",
            dependencies: ["URLSchemer"]),
    ]
)

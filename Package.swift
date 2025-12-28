// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCommonKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftCommonKit",
            targets: ["SwiftCommonKit"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftCommonKit",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SwiftCommonKitTests",
            dependencies: ["SwiftCommonKit"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
    ]
)

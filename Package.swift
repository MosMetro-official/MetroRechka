// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rechka",
    platforms: [
        .iOS(.v13),
    ],
    products: [
            .library(name: "Rechka", targets: ["Rechka"])
    ],
    dependencies: [
        .package(name: "CoreNetwork", url: "https://github.com/MosMetro-official/CoreNetwork", from: "0.0.2"),
        .package(name: "CoreTableView", url: "https://github.com/MosMetro-official/CoreTableView", from: "0.0.2"),
        .package(name: "SwiftDate", url: "https://github.com/malcommac/SwiftDate.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "Rechka",
            dependencies: [
                "CoreNetwork",
                "CoreTableView",
                "SwiftDate"
            ],
            resources: [
                .copy("Fonts/MoscowSans-Bold.otf"),
                .copy("Fonts/MoscowSans-Regular.otf"),
                .copy("Fonts/MoscowSans-Medium.otf")
            ]
        ),
        .testTarget(
            name: "RechkaTests",
            dependencies: ["Rechka"]
        )
    ]
)

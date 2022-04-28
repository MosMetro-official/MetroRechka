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
        .package(name: "MMCoreNetwork", url: "https://github.com/MosMetro-official/MMCoreNetwork", .exactItem("0.0.3-callbacks")),
//        .package(name: "CoreNetwork", url: "https://github.com/MosMetro-official/CoreNetwork", branch: "callbacks"),
        .package(name: "CoreTableView", url: "https://github.com/MosMetro-official/CoreTableView", from: "0.0.2"),
        .package(name: "SwiftDate", url: "https://github.com/malcommac/SwiftDate.git", from: "6.0.0"),
        .package(name: "SDWebImage", url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0"),
        .package(name: "YandexMobileMetrica", url: "https://github.com/yandexmobile/metrica-sdk-ios", from: "3.14.0")
    ],
    targets: [
        .target(
            name: "Rechka",
            dependencies: [
                "MMCoreNetwork",
                "CoreTableView",
                "SwiftDate",
                "SDWebImage",
                "YandexMobileMetrica"
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

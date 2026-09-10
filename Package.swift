// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftUIBoost",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SwiftUIBoostNotices", targets: ["SwiftUIBoostNotices"]),
        .library(name: "SwiftUIBoostPlaceholder", targets: ["SwiftUIBoostPlaceholder"]),
        .library(name: "SwiftUIBoostSkeleton", targets: ["SwiftUIBoostSkeleton"]),
        .library(name: "SwiftUIBoostPager", targets: ["SwiftUIBoostPager"]),
        .library(name: "SwiftUIBoostOverlay", targets: ["SwiftUIBoostOverlay"])
    ],
    targets: [
        .target(name: "SwiftUIBoostNotices"),
        .target(name: "SwiftUIBoostPlaceholder"),
        .target(name: "SwiftUIBoostSkeleton"),
        .target(name: "SwiftUIBoostPager"),
        .target(name: "SwiftUIBoostOverlay"),
        .testTarget(name: "SwiftUIBoostTests", dependencies: [
            "SwiftUIBoostNotices", "SwiftUIBoostPlaceholder", "SwiftUIBoostSkeleton",
            "SwiftUIBoostPager", "SwiftUIBoostOverlay"
        ])
    ]
)

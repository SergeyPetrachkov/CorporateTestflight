// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sharedPackage = Package.Dependency.package(path: "../CorporateTestflightShared")
let domainTargetDependency = Target.Dependency.product(name: "CorporateTestflightDomain", package: "CorporateTestflightShared")

let coreNetworking = "CoreNetworking"
let coreNetworkingTarget = Target.target(name: coreNetworking, dependencies: [], path: path(for: coreNetworking))
let coreNetworkingProduct = Product.library(name: coreNetworking, targets: [coreNetworking])
let coreNetworkingDependency = Target.Dependency.target(name: coreNetworking)

let testflightNetworking = "TestflightNetworking"
let testflightNetworkingTarget = Target.target(name: testflightNetworking, dependencies: [domainTargetDependency, coreNetworkingDependency], path: path(for: testflightNetworking))
let testflightNetworkingProduct = Product.library(name: testflightNetworking, targets: [testflightNetworking])

let testflightUIKit = "TestflightUIKit"
let testflightUIKitTarget = Target.target(name: testflightUIKit, path: path(for: testflightUIKit))
let testflightUIKitProduct = Product.library(name: testflightUIKit, targets: [testflightUIKit])

let package = Package(
    name: "CorporateTestflightClientCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        coreNetworkingProduct,
        testflightNetworkingProduct,
        testflightUIKitProduct
    ],
    dependencies: [
        sharedPackage,
    ],
    targets: [
        coreNetworkingTarget,
        testflightNetworkingTarget,
        testflightUIKitTarget
    ]
)

func path(for targetName: String) -> String {
    "Sources/\(targetName)"
}

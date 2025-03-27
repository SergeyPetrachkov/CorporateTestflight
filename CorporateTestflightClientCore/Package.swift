// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sharedPackage = Package.Dependency.package(path: "../CorporateTestflightShared")
let domainTargetDependency = Target.Dependency.product(name: "CorporateTestflightDomain", package: "CorporateTestflightShared")
let mockFuncPackage = Package.Dependency.package(name: "MockFunc", path: "../MockFunc")
let mockFuncDependency = Target.Dependency.product(name: "MockFunc", package: "MockFunc")

let swiftSettings = [SwiftSetting.swiftLanguageMode(.v6)]

let coreNetworking = "CoreNetworking"
let coreNetworkingTarget = Target.target(
	name: coreNetworking,
	dependencies: [],
	path: path(
		for: coreNetworking
	),
	swiftSettings: swiftSettings
)
let coreNetworkingProduct = Product.library(name: coreNetworking, targets: [coreNetworking])
let coreNetworkingDependency = Target.Dependency.target(name: coreNetworking)

let testflightNetworking = "TestflightNetworking"
let testflightNetworkingTarget = Target.target(
	name: testflightNetworking,
	dependencies: [domainTargetDependency, coreNetworkingDependency],
	path: path(for: testflightNetworking),
	swiftSettings: swiftSettings
)
let testflightNetworkingDependency = Target.Dependency.target(name: testflightNetworking)
let testflightNetworkingProduct = Product.library(name: testflightNetworking, targets: [testflightNetworking])

let testflightNetworkingMock = "TestflightNetworkingMock"
let testflightNetworkingMockTarget = Target.target(
	name: testflightNetworkingMock,
	dependencies: [domainTargetDependency, coreNetworkingDependency, testflightNetworkingDependency, mockFuncDependency],
	path: path(for: testflightNetworkingMock),
	swiftSettings: swiftSettings
)
let testflightNetworkingMockProduct = Product.library(name: testflightNetworkingMock, targets: [testflightNetworkingMock])

let testflightUIKit = "TestflightUIKit"
let testflightUIKitTarget = Target.target(
	name: testflightUIKit,
	path: path(
		for: testflightUIKit
	),
	swiftSettings: swiftSettings
)
let testflightUIKitProduct = Product.library(name: testflightUIKit, targets: [testflightUIKit])

let testflightFoundation = "TestflightFoundation"
let testflightFoundationTarget = Target.target(name: testflightFoundation, path: path(for: testflightFoundation), swiftSettings: swiftSettings)
let testflightFoundationProduct = Product.library(name: testflightFoundation, targets: [testflightFoundation])

let client = "Client"
let clientTarget = Target.target(
	name: client,
	dependencies: [
		domainTargetDependency,
		testflightNetworkingDependency
	],
	path: path(for: client),
	swiftSettings: swiftSettings
)
let clientProduct = Product.library(name: client, targets: [client])

let package = Package(
	name: "CorporateTestflightClientCore",
	platforms: [.macOS(.v13), .iOS(.v16)],
	products: [
		coreNetworkingProduct,
		testflightNetworkingProduct,
		testflightUIKitProduct,
		testflightFoundationProduct,
		clientProduct,
		// Mocks
		testflightNetworkingMockProduct
	],
	dependencies: [
		sharedPackage,
		mockFuncPackage
	],
	targets: [
		coreNetworkingTarget,
		testflightNetworkingTarget,
		testflightUIKitTarget,
		testflightFoundationTarget,
		testflightNetworkingMockTarget,
		clientTarget,
		.testTarget(name: "ClientTests", dependencies: ["Client", mockFuncDependency])
	]
)

func path(for targetName: String) -> String {
	"Sources/\(targetName)"
}

// swift-tools-version: 6.2

import PackageDescription

let moduleName = "JiraViewer"
let interfaceModuleName = "\(moduleName)Interface"

let swiftSettings = [
	SwiftSetting.swiftLanguageMode(.v6),
	.defaultIsolation(.none),
	.strictMemorySafety()
]

let uniFlowDependency = Target.Dependency.product(name: "UniFlow", package: "UniFlow")
let simpleDIDependency = Target.Dependency.product(name: "SimpleDI", package: "SimpleDI")
let domainDependency = Target.Dependency.product(name: "CorporateTestflightDomain", package: "CorporateTestflightShared")
let foundationDependency = Target.Dependency.product(name: "TestflightFoundation", package: "CorporateTestflightClientCore")
let imageLoaderDependency = Target.Dependency.product(name: "ImageLoader", package: "ImageLoader")
let networkingMockDependency = Target.Dependency.product(name: "TestflightNetworkingMock", package: "CorporateTestflightClientCore")
let imageLoaderMockDependency = Target.Dependency.product(name: "ImageLoaderMock", package: "ImageLoader")

let package = Package(
	name: moduleName,
	platforms: [.iOS(.v26), .macOS(.v26)],
	products: [
		.library(
			name: interfaceModuleName,
			targets: ["JiraViewerInterface"]
		),
		.library(
			name: moduleName,
			targets: ["JiraViewer"]
		)
	],
	dependencies: [
		.package(name: "UniFlow", path: "../UniFlow"),
		.package(name: "SimpleDI", path: "../SimpleDI"),
		.package(name: "CorporateTestflightShared", path: "../CorporateTestflightShared"),
		.package(name: "CorporateTestflightClientCore", path: "../CorporateTestflightClientCore"),
		.package(name: "ImageLoader", path: "../ImageLoader"),
		.package(name: "MockFunc", path: "../MockFunc")
	],
	targets: [
		.target(
			name: interfaceModuleName,
			dependencies: [
				uniFlowDependency,
				domainDependency,
				simpleDIDependency
			],
			swiftSettings: swiftSettings
		),
		.target(
			name: moduleName,
			dependencies: [
				.target(name: interfaceModuleName),
				uniFlowDependency,
				simpleDIDependency,
				domainDependency,
				imageLoaderDependency,
				foundationDependency
			],
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: "\(moduleName)Tests",
			dependencies: [
				.target(name: moduleName),
				.target(name: interfaceModuleName),
				uniFlowDependency,
				simpleDIDependency,
				domainDependency,
				imageLoaderDependency,
				foundationDependency,
				networkingMockDependency,
				imageLoaderMockDependency,
				"MockFunc"
			],
			swiftSettings: swiftSettings
		)
	]
)

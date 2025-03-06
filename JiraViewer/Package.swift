// swift-tools-version: 6.0

import PackageDescription

let moduleName = "JiraViewer"
let interfaceModuleName = "\(moduleName)Interface"

let swiftSettings = [SwiftSetting.swiftLanguageMode(.v6)]

let uniFlowDependency = Target.Dependency.product(name: "UniFlow", package: "UniFlow")
let simpleDIDependency = Target.Dependency.product(name: "SimpleDI", package: "SimpleDI")
let domainDependency = Target.Dependency.product(name: "CorporateTestflightDomain", package: "CorporateTestflightShared")
let imageLoaderDependency = Target.Dependency.product(name: "ImageLoader", package: "ImageLoader")

let package = Package(
	name: moduleName,
	platforms: [.iOS(.v17), .macOS(.v15)],
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
		.package(name: "ImageLoader", path: "../ImageLoader")
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
				imageLoaderDependency
			],
			swiftSettings: swiftSettings
		),
//		.testTarget(
//			name: "\(moduleName)Tests",
//			dependencies: []
//		),
	]
)

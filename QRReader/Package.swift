// swift-tools-version: 6.0

import PackageDescription

let moduleName = "QRReader"
let interfaceModuleName = "\(moduleName)Interface"

let swiftSettings = [SwiftSetting.swiftLanguageMode(.v6)]

let uniFlowDependency = Target.Dependency.product(name: "UniFlow", package: "UniFlow")
let simpleDIDependency = Target.Dependency.product(name: "SimpleDI", package: "SimpleDI")

let package = Package(
	name: moduleName,
	platforms: [.iOS(.v16)],
	products: [
		.library(
			name: interfaceModuleName,
			targets: ["QRReaderInterface"]
		),
		.library(
			name: moduleName,
			targets: ["QRReader"]
		)
	],
	dependencies: [
		.package(name: "UniFlow", path: "../UniFlow"),
		.package(name: "SimpleDI", path: "../SimpleDI"),
		.package(url: "https://github.com/apple/swift-async-algorithms", branch: "main")
	],
	targets: [
		.target(
			name: interfaceModuleName,
			dependencies: [
				uniFlowDependency
			],
			swiftSettings: swiftSettings
		),
		.target(
			name: moduleName,
			dependencies: [
				.target(name: interfaceModuleName),
				uniFlowDependency,
				simpleDIDependency,
				.product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
			],
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: "QRReaderTests",
			dependencies: ["QRReader"]
		),
	]
)

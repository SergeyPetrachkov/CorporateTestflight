// swift-tools-version: 6.0

import PackageDescription

let moduleName = "QRReader"
let interfaceModuleName = "\(moduleName)Interface"

let swiftSettings = [SwiftSetting.swiftLanguageMode(.v6)]

let uniFlowDependency = Target.Dependency.product(name: "UniFlow", package: "UniFlow")

let package = Package(
	name: moduleName,
	platforms: [.iOS(.v16)],
	products: [
		.library(
			name: interfaceModuleName,
			type: .dynamic,
			targets: ["QRReaderInterface"]
		),
		.library(
			name: moduleName,
			targets: ["QRReader"]
		)
	],
	dependencies: [
		.package(name: "UniFlow", path: "../UniFlow"),
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

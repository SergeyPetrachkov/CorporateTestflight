// swift-tools-version: 6.0

import PackageDescription

let moduleName = "VersionsBrowser"
let interfaceModuleName = "\(moduleName)Interface"

let swiftSettings = [SwiftSetting.swiftLanguageMode(.v6)]

let uniFlowDependency = Target.Dependency.product(name: "UniFlow", package: "UniFlow")
let simpleDIDependency = Target.Dependency.product(name: "SimpleDI", package: "SimpleDI")
let domainDependency = Target.Dependency.product(name: "CorporateTestflightDomain", package: "CorporateTestflightShared")
let testflightUIKit = Target.Dependency.product(name: "TestflightUIKit", package: "CorporateTestflightClientCore")
let jiraViewerInterface = Target.Dependency.product(name: "JiraViewerInterface", package: "JiraViewer")

let package = Package(
	name: moduleName,
	platforms: [.iOS(.v18), .macOS(.v15)],
	products: [
		.library(
			name: interfaceModuleName,
			targets: [interfaceModuleName]
		),
		.library(
			name: moduleName,
			targets: [moduleName]
		)
	],
	dependencies: [
		.package(name: "UniFlow", path: "../UniFlow"),
		.package(name: "SimpleDI", path: "../SimpleDI"),
		.package(name: "CorporateTestflightShared", path: "../CorporateTestflightShared"),
		.package(name: "CorporateTestflightClientCore", path: "../CorporateTestflightClientCore"),
		.package(name: "JiraViewer", path: "../JiraViewer"),
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
				testflightUIKit,
				jiraViewerInterface
			],
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: "\(moduleName)Tests",
			dependencies: [
				"VersionsBrowser",
				"VersionsBrowserInterface",
				"MockFunc",
				domainDependency
			]
		),
	]
)

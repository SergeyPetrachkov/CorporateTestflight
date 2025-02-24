// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "UniFlow",
	products: [
		.library(
			name: "UniFlow",
			targets: ["UniFlow"]
		),
	],
	targets: [
		.target(name: "UniFlow", swiftSettings: [.swiftLanguageMode(.v6)])
	]
)

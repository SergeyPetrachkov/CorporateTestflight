// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "UniFlow",
	platforms: [.iOS(.v16)],
	products: [
		.library(
			name: "UniFlow",
			targets: ["UniFlow"]
		)
	],
	targets: [
		.target(
			name: "UniFlow",
			swiftSettings: [
				.swiftLanguageMode(.v6),
				.defaultIsolation(.none),
				.strictMemorySafety()
			]
		)
	]
)

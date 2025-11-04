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
				.defaultIsolation(.none), // even if we set MainActor.self, the protocols here won't be isolated in the modularized proj
				.strictMemorySafety()
			]
		)
	]
)

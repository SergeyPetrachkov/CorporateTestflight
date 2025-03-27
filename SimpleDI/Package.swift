// swift-tools-version: 5.10

import PackageDescription

let package = Package(
	name: "SimpleDI",
	platforms: [.iOS(.v16)],
	products: [
		.library(
			name: "SimpleDI",
			targets: ["SimpleDI"]
		)
	],
	targets: [
		.target(
			name: "SimpleDI"
		),
		.testTarget(
			name: "SimpleDITests",
			dependencies: ["SimpleDI"]
		)
	]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "ImageLoader",
	platforms: [.iOS(.v16), .macOS(.v13)],
	products: [
		.library(
			name: "ImageLoader",
			targets: ["ImageLoader"]
		),
	],
	dependencies: [
		.package(name: "CorporateTestflightClientCore", path: "../CorporateTestflightClientCore"),
		.package(name: "MockFunc", path: "../MockFunc")
	],
	targets: [
		.target(
			name: "ImageLoader",
			dependencies: [
				.product(name: "TestflightNetworking", package: "CorporateTestflightClientCore")
			],
			swiftSettings: [.swiftLanguageMode(.v6)]
		),
		.testTarget(
			name: "ImageLoaderTests",
			dependencies: [
				"ImageLoader",
				.product(name: "TestflightNetworkingMock", package: "CorporateTestflightClientCore"),
				.product(name: "MockFunc", package: "MockFunc")
			],
			swiftSettings: [.swiftLanguageMode(.v6)]
		),
	]
)


// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "ImageLoader",
	platforms: [.iOS(.v16), .macOS(.v15)],
	products: [
		.library(
			name: "ImageLoader",
			targets: ["ImageLoader"]
		),
		.library(
			name: "ImageLoaderMock",
			targets: ["ImageLoaderMock"]
		)
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
		.target(
			name: "ImageLoaderMock",
			dependencies: [
				"ImageLoader",
				"MockFunc"
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
		)
	]
)

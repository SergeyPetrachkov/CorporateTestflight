// swift-tools-version: 6.0

import PackageDescription

let mockFuncName = "MockFunc"
let mockFuncTestsName = "MockFuncTests"

let package = Package(
	name: mockFuncName,
	platforms: [.iOS(.v13), .macOS(.v12), .watchOS(.v10)],
	products: [
		.library(
			name: mockFuncName,
			targets: [
				mockFuncName
			]
		)
	],
	targets: [
		.target(
			name: mockFuncName,
			path: mockFuncName,
			swiftSettings: [
				.swiftLanguageMode(.v6)
			]
		),
		.testTarget(
			name: mockFuncTestsName,
			dependencies: [
				.target(name: mockFuncName)
			],
			path: mockFuncTestsName,
			swiftSettings: [
				.swiftLanguageMode(.v6)
			]
		)
	]
)

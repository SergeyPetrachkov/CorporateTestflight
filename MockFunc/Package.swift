// swift-tools-version: 6.0

import PackageDescription

let mockFuncName = "MockFunc"
let mockFuncTestsName = "MockFuncTests"

let swiftSettings: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
	name: mockFuncName,
	platforms: [.iOS(.v13), .macOS(.v15), .watchOS(.v10)],
	products: [
		.library(
			name: mockFuncName,
			targets: [
				mockFuncName
			]
		),
	],
	targets: [
		.target(
			name: mockFuncName,
			path: mockFuncName,
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: mockFuncTestsName,
			dependencies: [
				.target(name: mockFuncName)
			],
			path: mockFuncTestsName,
			swiftSettings: swiftSettings
		),
	]
)

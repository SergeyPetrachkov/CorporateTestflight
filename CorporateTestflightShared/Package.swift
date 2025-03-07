// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let domain = "CorporateTestflightDomain"
let domainTarget = Target.target(
	name: domain,
	path: path(
		for: domain
	),
	swiftSettings: [
		.enableExperimentalFeature(
			"StrictConcurrency"
		)
	]
)
let domainProduct = Product.library(name: domain, targets: [domain])

let package = Package(
	name: "CorporateTestflightShared",
	platforms: [.iOS(.v16), .macOS(.v13)],
	products: [
		domainProduct
	],
	targets: [
		domainTarget
	]
)

func path(for targetName: String) -> String {
	"Sources/\(targetName)"
}

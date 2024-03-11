// swift-tools-version:5.9
import PackageDescription

let sharedPackage = Package.Dependency.package(path: "../CorporateTestflightShared")
let domainTargetDependency = Target.Dependency.product(name: "CorporateTestflightDomain", package: "CorporateTestflightShared")

let package = Package(
    name: "CorporateTestflightBackend-Package",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.1"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🪶 Fluent driver for SQLite.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
        // 💎 Our shared code
        sharedPackage
    ],
    targets: [
        .executableTarget(
            name: "CorporateTestflightBackend",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                domainTargetDependency
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "CorporateTestflightBackend"),
                .product(name: "XCTVapor", package: "vapor"),

                // Workaround for https://github.com/apple/swift-package-manager/issues/6940
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "Fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ]
        )
    ]
)

# Corporate Testflight
[![iOS HealthCheck](https://github.com/SergeyPetrachkov/CorporateTestflight/actions/workflows/ios.yml/badge.svg)](https://github.com/SergeyPetrachkov/CorporateTestflight/actions/workflows/ios.yml)

The purpose of this repo is not to create a system, but to serve a sample project for mastering the new Swift Concurrency.

## Prerequisites

* macOS
* admin access
* Xcode 26
* basic knowledge of the Swift Concurrency
* basic knowledge of SwiftUI

## How to use the repo

* Open `CorporateTestflightPlatform.xcworkspace` in your Xcode and wait for all dependencies to load
* Before launching the iOS app you need to launch an instance of our Backend. Choose `CorporateTestflightBackend`, go to Edit scheme -> Run -> Options -> Use custom working directory and put the CorporateTestflightBackend there. Then run the scheme (it'll ask you for admin access, it's fine, it's the way Vapor works)
* Without stopping the backend, choose `CorporateTestflightClient` as your active scheme, select your favorite simulator and run the project.

## The repo structure

This is a monorepo for the whole system, which includes the backend, frontend and shared codebase (all in Swift).
Horizontals represent modules that form a foundation of the project. Modules that will be reused by Verticals.
Verticals are feature flows. We have Versions browser flow, Jira ticket viewer and a QR-codes scanner.

Each package has tests. Some tests are written with XCTest, others - with Swift Testing. There's a testplan that aggregates all tests. You can run them as `make test_app`. You can build the project as `make build_app`.

### CorporateTestflightClientCore
CorporateTestflightClientCore is cluttered, it should be re-organized, from the name of it you can see that it's not responsible for one thing, but for many. This is not ideal :)

### SimpleDI

I took an interface of Swinject and implemented a super-simplified version of it. It's not a high-scale production ready solution :)

### ImageLoader

A field for experiments on actors, and locks, and NSCache. The idea is to centralise image loading through the one networking layer like it's done in big projects, so all requests are under control.

### UniFlow

A couple of highly opinionated protocols that define how we organise our scenes.

### MockFunc

See the respective Readme of the package. 

### Verticals

All verticals are organised in a way that a vertical has 2 parts: interface and implementation. If one vertical needs access to another vertical, it reaches out to it's interface part. This way we make sure our build graph won't suffer from transitive dependencies and eventual circular dependencies. Interface only has protocols and structs/enums that are responsible for cross-module communications, i.e. inputs and outputs of a module.
Implementation part only contains one public part: Assembly where everything is being registered and then linked to the main app.
This way a module is a black-box and one can only work with it via inputs and outputs.

## Workshop structure

To start, you need to checkout `workshop` branch. Main branch is the reference. 
We only gonna work in the Horizontals and Verticals of the project. Backend and the shared codebase are not in the scope of the workshop.

* We will be filling in the blanks together during the live-coding sessions via TDD.
* We will also do the opposite: write tests for the existing code and compare Swift Testing with XCTest.
* In the end there will be Q&A session.

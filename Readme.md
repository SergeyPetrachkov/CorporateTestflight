# Corporate Testflight

The purpose of this repo is not to create a system, but to serve a sample project for mastering the new Swift Concurrency.

## Prerequisites

* macOS
* admin access
* Homebrew
* Xcode 15.1 

## Before opening Xcode

* install Vapor toolbox by `brew install vapor`

## How to use the repo

* Open `CorporateTestflightPlatform.xcworkspace` in your Xcode and wait for all dependencies to load
* Before launching the iOS app you need to launch an instance of our Backend. Choose `CorporateTestflightBackend` as your active scheme and run the scheme (it'll ask you for admin access, it's fine, it's the way Vapor works)
* Without stopping the backend, choose `CorporateTestflightClient` as your active scheme, select your favorite simulator and run the project.

## The structure

This is a monorepo for the whole system, which includes the backend, frontend and shared codebase (all in Swift).
We will be working in the Client part to go through the steps of our workshop.

TODO: add the steps  

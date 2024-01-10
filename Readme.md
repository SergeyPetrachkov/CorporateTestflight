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

## Task #1 (We all do stuff together)

Create the first screen of the app.
For that you'll need to:

* Update the interfaces of the `VersionsList` VIP stack. All the entities are created and connected.
* Inject all the necessary dependencies (`VersionsRepository`, `ProjectsRepository`). Use `AppDependencies` for that.
* Implement the async request(s) and make the result display in the UI.
* Implement navigation from the list to the details.

## Task #2 (UIKit vs SwiftUI)

Upgrade the version details screen with business logic.
You'll need:

* An instance of `TicketsRepository` to download tickets details.
* Either updated ViewModel or VIP stack of the VersionDetails. 
* Every `Version` has `associatedTicketKeys` and we need to send requests for each of them. Any request can fail and/or can throw an error. This must not interfere with the rest of the requests.
* The screen must have 3 states: Loading/Loaded/Failed.
* If we exit the screen (swipe to pop), we must cancel all the ongoing requests.
* (Advanced) we must not load the same ticket multiple times, we should have a (runtime) cache and we should check if we are already loading the ticket before loading it again.

## Task #3 (Tests)

Let's write some tests together for interactors, presenters, view models (if we have time).

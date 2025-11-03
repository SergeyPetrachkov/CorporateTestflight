# Corporate Testflight - AI Coding Agent Instructions

## Project Overview
Corporate Testflight is a Swift Concurrency learning monorepo with iOS client, Vapor backend, and shared modules. Built with Swift 6, SwiftUI, and strict concurrency patterns.

## Architecture Patterns

### Vertical/Interface Separation
Modules split into Interface (protocols + public types) and Implementation (Assembly registration):
- `JiraViewer/JiraViewerInterface` - Cross-module contracts
- `VersionsBrowser/VersionsBrowserInterface` - Flow coordination protocols
- Implementation modules contain single public Assembly for DI registration

### Flow Coordination Pattern (UniFlow)
Coordinators manage navigation flows using `SyncFlowEngine`/`FlowEngine` protocols:
```swift
// Interface defines contract
public protocol VersionsBrowserCoordinator: SyncFlowEngine where Input == VersionsBrowserFlowInput {
    var output: ((VersionsBrowserOutput) -> Void)? { get set }
}

// Implementation handles navigation
final class VersionsListCoordinator: VersionsBrowserCoordinator {
    // Factory provides dependencies, Store manages state
}
```

### State Management (Store Pattern)
Observable stores handle async actions with environment dependencies:
```swift
final class VersionsListStore: ObservableObject, Store {
    @Published var state: State
    let environment: Environment
    
    func send(_ action: Action) async {
        // Handle action, update state
    }
}
```

### Dependency Injection (SimpleDI)
Custom DI container with Assembly pattern:
```swift
// SceneDelegate bootstraps all assemblies
let assemblies: [any Assembly] = [
    AppAssembly(),
    VersionsBrowserAssembly(),
    QRReaderAssembly(),
    JiraViewerAssembly()
]
```

## Testing with MockFunc

### Thread-Safe Mocking (Swift 6 Ready)
Use appropriate mock based on concurrency needs:
- `MockFunc<Input, Output>` - Non-thread-safe, sync/async functions
- `ThreadSafeMockFunc<Input, Output>` - Actor-based for concurrent code
- `ThreadSafeMockThrowingTypedErrorFunc<Input, Output, ErrorType>` - Typed error throwing

```swift
final class MockSomeAPI: SomeAPIProtocol {
    let searchMock = ThreadSafeMockFunc<String, SearchResponse>()
    
    func search(query: String) async -> SearchResponse {
        await searchMock.callAndReturn(query)
    }
}
```

## Development Workflows

### Build Commands
- `make build_app` - Build iOS app targeting iPhone 16 simulator
- `make test_app` - Run unified test plan (CorporateTestflightClientTests)
- `make format` - Format code with swift-format (uses .swift-format config)
- `make periphery` - Run dead code analysis

### Backend Setup
1. Set CorporateTestflightBackend as custom working directory in scheme
2. Run backend first (requires admin access for Vapor on port 8080)
3. Backend serves JSON from `Public/` directory (tickets.json, versions.json)
4. Then run CorporateTestflightClient connecting to localhost:8080

### Swift 6 Strict Concurrency Settings
All packages use:
```swift
swiftSettings: [
    .swiftLanguageMode(.v6),
    .defaultIsolation(.none),  // or MainActor for UI modules
    .strictMemorySafety()
]
```

## Key File Locations
- `SceneDelegate.swift` - App bootstrap and DI container setup with all assemblies
- `*/Assembly/*Assembly.swift` - Module dependency registration
- `*/Sources/*/Flow/*Factory.swift` - Scene creation and navigation
- `*/Sources/*/Scenes/*/Store.swift` - State management with Store pattern
- `UniFlow/` - Navigation flow protocols (SyncFlowEngine/FlowEngine)
- `MockFunc/` - Testing framework with actor support

## Package Structure
- `CorporateTestflightClient/` - iOS app (Xcode project)
- `CorporateTestflightBackend/` - Vapor server (SQLite + JSON serving)
- `CorporateTestflightClientCore/` - Networking, Foundation utilities
- `CorporateTestflightShared/` - Domain models
- `JiraViewer/` - Ticket viewing module (Interface + Implementation)
- `VersionsBrowser/` - Version browsing module (Interface + Implementation)
- `QRReader/` - QR scanning module (AVFoundation + AsyncAlgorithms)
- `SimpleDI/` - Dependency injection framework
- `UniFlow/` - Navigation flow coordination
- `MockFunc/` - Testing framework with concurrency support
- `ImageLoader/` - Image loading (Interface + Mock)

## SwiftUI Navigation
Uses modern NavigationStack patterns. Coordinators handle UIKit integration while scenes use SwiftUI internally.

When working in this codebase, respect the vertical architecture boundaries, use appropriate mock types for concurrency context, and follow the Flow→Factory→Store→Environment pattern for new features.

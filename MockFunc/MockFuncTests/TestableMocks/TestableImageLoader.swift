import Foundation
import MockFunc

struct ImageCacheItem: Equatable {
	let imageData: Image
}

struct Image: Equatable {
	let data: Data
}

enum ImageLoadingError: Error, Equatable {
	case test
}

/// This is a Mock that will be tested. It contains all sorts of nonsense functions, don't mind them.
///
/// This is also marked as unchecked Sendable to be able to do the thread safety test with the task group. Swift 6 compiler is very strict about it.
/// Our mocks don't usually have Sendability specified. But most of them are not thread-safe either.
/// When we need thread safe mocks and we need to perform concurrent operations on top, we can update the generator to add Sendability.
final class MockImageLoader: @unchecked Sendable {

	// MARK: - Sync API
	typealias LoadUrlItemCompletionInput = (
		url: URL,
		item: ImageCacheItem
	)

	let loadUrlWithCompletionMock = MockFunc<LoadUrlItemCompletionInput, (ImageCacheItem, Image?)>()
	func load(url: URL, item: ImageCacheItem, completion: @escaping @MainActor @Sendable (ImageCacheItem, Image?) -> Void) {
		loadUrlWithCompletionMock.callAndReturn((url, item), completion: completion)
	}

	let loadUrlWithNonIsolatedCompletionMock = MockFunc<LoadUrlItemCompletionInput, (ImageCacheItem, Image?)>()
	func loadNonIsolated(url: URL, item: ImageCacheItem, nonIsolatedCompletion: @escaping @Sendable (ImageCacheItem, Image?) -> Void) {
		loadUrlWithNonIsolatedCompletionMock.callAndReturn((url, item), completion: nonIsolatedCompletion)
	}

	let loadUrlMock = MockFunc<URL, Image>()
	func load(url: URL) -> Image {
		loadUrlMock.callAndReturn(url)
	}

	let loadUrlThrowingMock = MockThrowingFunc<URL, Image>()
	func loadThrowing(url: URL) throws -> Image {
		try loadUrlThrowingMock.callAndReturn(url)
	}


	let loadTypedThrowsMock = MockThrowingTypedErrorFunc<URL, Image, ImageLoadingError>()
	func loadTypedThrowing(url: URL) throws(ImageLoadingError) -> Image {
		try loadTypedThrowsMock.callAndReturn(url)
	}

	let loadResultMock = MockFunc<URL, Result<Image, Error>>()
	func loadResult(url: URL) -> Result<Image, Error> {
		loadResultMock.callAndReturn(url)
	}

	let purgeMock = MockFunc<Void, Void>()
	func purge() {
		purgeMock.call()
	}

	let purgeThrowingMock = MockThrowingFunc<Void, Void>()
	func purgeThrows() throws {
		try purgeThrowingMock.callAndReturn(())
	}

	let lastLoadedMock = MockFunc<Void, Image?>()
	func lastLoaded() -> Image? {
		lastLoadedMock.callAndReturn()
	}

	let purgeWithResultMock = MockFunc<Void, Result<Void, Error>>()
	func purgeWithResult() -> Result<Void, Error> {
		purgeWithResultMock.callAndReturn()
	}

	let lastLoadedThrowingMock = MockThrowingFunc<Void, Image?>()
	func lastLoadedThrows() throws -> Image? {
		try lastLoadedThrowingMock.callAndReturn(())
	}

	let purgeWithCompletionThrowingMock = MockThrowingFunc<() -> Void, Void>()
	func purgeThrows(onFinish: @escaping () -> Void) throws {
		try purgeWithCompletionThrowingMock.callAndReturn(onFinish)
	}

	// MARK: - Async API

	let loadAsyncUrlMock = ThreadSafeMockFunc<URL, Image>()
	func loadAsync(url: URL) async -> Image {
		await loadAsyncUrlMock.callAndReturn(url)
	}

	let loadAsyncThrowsUrlMock = ThreadSafeMockThrowingFunc<URL, Image>()
	func loadAsyncThrows(url: URL) async throws -> Image {
		try await loadAsyncThrowsUrlMock.callAndReturn(url)
	}

	let loadAsyncResultMock = ThreadSafeMockFunc<URL, Result<Image, Error>>()
	func loadAsyncResult(url: URL) async -> Result<Image, Error> {
		await loadAsyncResultMock.callAndReturn(url)
	}

	let purgeAsyncMock = ThreadSafeMockFunc<Void, Void>()
	func purgeAsync() async {
		await purgeAsyncMock.callAndReturn()
	}

	let purgeAsyncThrowingMock = ThreadSafeMockThrowingFunc<Void, Void>()
	func purgeAsyncThrows() async throws {
		try await purgeAsyncThrowingMock.callAndReturn(())
	}

	let lastLoadedAsyncMock = ThreadSafeMockFunc<Void, Image?>()
	func lastLoadedAsync() async -> Image? {
		await lastLoadedAsyncMock.callAndReturn()
	}

	let purgeWithResultAsyncMock = ThreadSafeMockFunc<Void, Result<Void, Error>>()
	func purgeWithResultAsync() async -> Result<Void, Error> {
		await purgeWithResultAsyncMock.callAndReturn()
	}

	let lastLoadedThrowingAsyncMock = ThreadSafeMockThrowingFunc<Void, Image?>()
	func lastLoadedAsyncThrows() async throws -> Image? {
		try await lastLoadedThrowingAsyncMock.callAndReturn(())
	}
}

/// This is a "super thread safe" mock, access to the internal state is always synchronized
actor ActorMock {

	let purgeAsyncMock = ThreadSafeMockFunc<Void, Void>()

	func purgeAsync() async {
		await purgeAsyncMock.callAndReturn()
	}
}

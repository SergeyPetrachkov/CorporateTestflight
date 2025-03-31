import Foundation
import ImageLoader
import TestflightNetworking
import TestflightNetworkingMock
import Testing

// Plan: 7.4 ImageLoader Tests
// Concurrency tests
// require vs expect
// await expect throws

@Suite("Actor Image Cache Tests")
struct ImageLoaderTests {

	struct Environment {
		let url = URL(string: "https://example.com/image.jpg")!
		let expectedImage = LoadableImage(systemName: "circle", variableValue: 0)!
		let apiService = TestflightAPIProvidingMock()

		func makeSUT() -> ImageCache {
			ImageCache(apiService: apiService)
		}
	}

	@Test
	func returnsImageWhenImageExists() async throws {
		// Given
		let env = Environment()

		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		// When
		let result = try await sut.load(url: env.url)

		// Then
		_ = try #require(result)
		#expect(await env.apiService.getResourceMock.calledOnce)
	}

	@Test
	func returnsCachedImageWhenImageWasLoadedBefore() async throws {
		// Given
		let env = Environment()
		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		// When
		_ = try await sut.load(url: env.url)
		_ = try await sut.load(url: env.url)

		// Then
		#expect(await env.apiService.getResourceMock.calledOnce)
	}

	@Test
	func reusesSameTaskWhenLoadingImageConcurrently() async throws {
		// Given
		let env = Environment()
		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		// When
		async let firstLoad = sut.load(url: env.url)
		async let secondLoad = sut.load(url: env.url)

		// Then
		_ = try await (firstLoad, secondLoad)
		#expect(await env.apiService.getResourceMock.calledOnce)
	}

	@Test
	func throwsErrorWhenImageDataIsInvalid() async throws {
		// Given
		let env = Environment()
		await env.apiService.getResourceMock.returns(Data("invalid image data".utf8))
		let sut = env.makeSUT()

		await #expect(throws: ImageCache.ImageCacheError.failedDownloadingImage(env.url)) {
			_ = try await sut.load(url: env.url)
		}
	}

	@Test
	func createsNewTaskWhenPreviousTaskFailed() async throws {
		// Given
		let env = Environment()
		let expectedError = NSError(domain: "test", code: -1)
		await env.apiService.getResourceMock.throws(expectedError)
		let sut = env.makeSUT()

		await #expect(throws: expectedError) {
			_ = try await sut.load(url: env.url)
		}

		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let result = try await sut.load(url: env.url)

		// Then
		_ = try #require(result)
		#expect(await env.apiService.getResourceMock.count == 2)
	}

	@Test
	func evictsCacheWhenLimitExceeded() async throws {
		// Given
		let env = Environment()
		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		// When
		for i in 0...3 {
			let url = URL(string: "https://example.com/image\(i).jpg")!
			_ = try await sut.load(url: url)
		}

		// Then
		let firstURL = URL(string: "https://example.com/image0.jpg")!
		_ = try await sut.load(url: firstURL)
		#expect(await env.apiService.getResourceMock.count == 5)
	}

	@Test
	func threadSafety() async throws {

		let env = Environment()
		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		await withTaskGroup(of: Void.self) { group in
			for _ in 0..<100 {
				group.addTask {
					let url = URL(string: "https://example.com/image.jpg")!
					_ = try? await sut.load(url: url)
				}
			}
		}
		let callsCount = await env.apiService.getResourceMock.count
		#expect(callsCount == 1)
	}
}

import Foundation
import ImageLoader
import TestflightNetworking
import TestflightNetworkingMock
import Testing

@Suite("Conservative Image Cache Tests")
struct ConservativeImageCacheTests {

	struct Environment {
		let url = URL(string: "https://example.com/image.jpg")!
		let expectedImage = LoadableImage(systemName: "circle", variableValue: 0)!
		let apiService = TestflightAPIProvidingMock()

		func makeSUT() -> ConservativeImageCache {
			ConservativeImageCache(apiService: apiService)
		}
	}

	@Test
	func returnsImageWhenImageExists() async throws {
		let env = Environment()

		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		let result = try await sut.load(url: env.url)

		_ = try #require(result)
		#expect(await env.apiService.getResourceMock.calledOnce)
	}

	@Test
	func returnsCachedImageWhenImageWasLoadedBefore() async throws {
		let env = Environment()
		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		_ = try await sut.load(url: env.url)
		_ = try await sut.load(url: env.url)

		#expect(await env.apiService.getResourceMock.calledOnce)
	}

	@Test
	func reusesSameTaskWhenLoadingImageConcurrently() async throws {
		let env = Environment()
		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		async let firstLoad = sut.load(url: env.url)
		async let secondLoad = sut.load(url: env.url)

		_ = try await (firstLoad, secondLoad)
		#expect(await env.apiService.getResourceMock.calledOnce)
	}

	@Test
	func throwsErrorWhenImageDataIsInvalid() async throws {
		let env = Environment()
		await env.apiService.getResourceMock.returns(Data("invalid image data".utf8))
		let sut = env.makeSUT()

		await #expect(throws: ConservativeImageCache.ImageCacheError.failedDownloadingImage(env.url)) {
			_ = try await sut.load(url: env.url)
		}
	}

	@Test
	func createsNewTaskWhenPreviousTaskFailed() async throws {
		let env = Environment()
		let expectedError = NSError(domain: "test", code: -1)
		await env.apiService.getResourceMock.throws(expectedError)
		let sut = env.makeSUT()

		await #expect(throws: expectedError) {
			_ = try await sut.load(url: env.url)
		}

		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let result = try await sut.load(url: env.url)

		_ = try #require(result)
		#expect(await env.apiService.getResourceMock.count == 2)
	}

	@Test
	func evictsCacheWhenLimitExceeded() async throws {
		let env = Environment()
		await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
		let sut = env.makeSUT()

		for i in 0...3 {
			let url = URL(string: "https://example.com/image\(i).jpg")!
			_ = try await sut.load(url: url)
		}

		let firstURL = URL(string: "https://example.com/image0.jpg")!
		_ = try await sut.load(url: firstURL)
		#expect(await env.apiService.getResourceMock.count == 5)
	}

	@Test
	func handlesMutexCleanupCorrectly() async throws {
		let env = Environment()
		let expectedError = NSError(domain: "test", code: -1)
		await env.apiService.getResourceMock.throws(expectedError)
		let sut = env.makeSUT()

		for _ in 0...5 {
			await #expect(throws: expectedError) {
				_ = try await sut.load(url: env.url)
			}
		}
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

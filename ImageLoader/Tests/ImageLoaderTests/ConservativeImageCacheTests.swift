import Foundation
import ImageLoader
import TestflightNetworking
import TestflightNetworkingMock
import Testing

@Suite("Conservative Image Cache Tests")
struct ConservativeImageCacheTests {

	@available(iOS 18.0, *)
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
		if #available(iOS 18.0, *) {
			// Given
			let env = Environment()

			await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
			let sut = env.makeSUT()

			// When
			let result = try await sut.load(url: env.url)

			// Then
			_ = try #require(result)
			#expect(await env.apiService.getResourceMock.calledOnce)
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}

	@Test
	func returnsCachedImageWhenImageWasLoadedBefore() async throws {
		// Given
		if #available(iOS 18.0, *) {
			let env = Environment()
			await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
			let sut = env.makeSUT()

			// When
			_ = try await sut.load(url: env.url)
			_ = try await sut.load(url: env.url)

			// Then
			#expect(await env.apiService.getResourceMock.calledOnce)
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}

	@Test
	func reusesSameTaskWhenLoadingImageConcurrently() async throws {
		if #available(iOS 18.0, *) {
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
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}

	@Test
	func throwsErrorWhenImageDataIsInvalid() async throws {
		if #available(iOS 18.0, *) {
			// Given
			let env = Environment()
			await env.apiService.getResourceMock.returns(Data("invalid image data".utf8))
			let sut = env.makeSUT()

			await #expect(throws: ConservativeImageCache.ImageCacheError.failedDownloadingImage(env.url)) {
				_ = try await sut.load(url: env.url)
			}
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}

	@Test
	func createsNewTaskWhenPreviousTaskFailed() async throws {
		if #available(iOS 18.0, *) {
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
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}

	@Test
	func evictsCacheWhenLimitExceeded() async throws {
		if #available(iOS 18.0, *) {
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
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}

	@Test
	func handlesMutexCleanupCorrectly() async throws {
		if #available(iOS 18.0, *) {
			// Given
			let env = Environment()
			let expectedError = NSError(domain: "test", code: -1)
			await env.apiService.getResourceMock.throws(expectedError)
			let sut = env.makeSUT()

			// When/Then
			for _ in 0...5 {
				await #expect(throws: expectedError) {
					_ = try await sut.load(url: env.url)
				}
			}
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}

	@Test
	func threadSafety() async throws {
		if #available(iOS 18.0, *) {
			// Given
			let env = Environment()
			await env.apiService.getResourceMock.returns(env.expectedImage.pngData()!)
			let sut = env.makeSUT()


			await withTaskGroup(of: Void.self) { group in
				for i in 0..<100 {
					group.addTask {
						let url = URL(string: "https://example.com/image.jpg")!
						_ = try? await sut.load(url: url)
					}
				}

				for await _ in group {}
			}
			let callsCount = await env.apiService.getResourceMock.count
			#expect(callsCount == 1)
		} else {
			// helaas pindakaas. Testing + availble + macros don't work together
		}
	}
}

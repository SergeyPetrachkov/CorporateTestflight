import Foundation
import Synchronization
import TestflightNetworking

@available(iOS 18.0, *)
public final class MutexImageCache: ImageLoader, Sendable {

	public enum ImageCacheError: Error, Equatable {
		case failedDownloadingImage(URL)
	}

	// MARK: - Injectables
	private let apiService: TestflightAPIProviding

	// MARK: - State
	private nonisolated(unsafe) let cache: NSCache<NSURL, LoadableImage> = {
		let cache = NSCache<NSURL, LoadableImage>()
		cache.countLimit = 3
		cache.evictsObjectsWithDiscardedContent = true
		cache.name = "com.corporate-testflight.ImageCache"
		return cache
	}()

	private let synchronizedRegisteredTasks: Mutex<[URL: Task<LoadableImage, any Error>]> = .init([:])

	// MARK: - Initializer
	public init(apiService: TestflightAPIProviding) {
		self.apiService = apiService
	}

	/// Load an image by a given URL.
	public func load(url: URL) async throws -> LoadableImage {
		if let cachedImage = unsafe cache.object(forKey: url as NSURL) {
			return cachedImage
		}
		let loadingTask = getOrCreateTask(for: url)

		return try await loadingTask.value
	}

	private func getOrCreateTask(for url: URL) -> Task<LoadableImage, any Error> {
		synchronizedRegisteredTasks.withLock { registeredTasks in
			if let currentActiveTask = registeredTasks[url] {
				return currentActiveTask
			} else {
				let newLoadingTask = fetchImageTask(for: url)
				registeredTasks[url] = newLoadingTask
				return newLoadingTask
			}
		}
	}

	/// Create a new Task that handles the fetch request and puts it into the cache.
	private func fetchImageTask(for url: URL) -> Task<LoadableImage, any Error> {
		Task {
			defer {
				synchronizedRegisteredTasks.withLock { registeredTasks in
					registeredTasks[url] = nil
				}
			}
			let responseData = try await apiService.getResource(url: url)
			guard let image = LoadableImage(data: responseData) else {
				throw ImageCacheError.failedDownloadingImage(url)
			}

			unsafe cache.setObject(image, forKey: url as NSURL, cost: responseData.count)

			return image
		}
	}
}

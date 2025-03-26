import Foundation
import TestflightNetworking
import Synchronization

@available(iOS 18.0, *)
public final class ConservativeImageCache: ImageLoader, @unchecked Sendable {

	public enum ImageCacheError: Error, Equatable {
		case failedDownloadingImage(URL)
	}

	// MARK: - Injectables
	private let apiService: TestflightAPIProviding

	// MARK: - State
	private let cache: NSCache<NSURL, LoadableImage> = {
		let cache = NSCache<NSURL, LoadableImage>()
		cache.countLimit = 3
		cache.evictsObjectsWithDiscardedContent = true
		cache.name = "com.corporate-testflight.ConservativeImageCache"
		return cache
	}()

	private let registeredTasks = Mutex<[URL: Task<LoadableImage, any Error>]>([:])

	// MARK: - Initializers
	public init(apiService: TestflightAPIProviding) {
		self.apiService = apiService
	}

	// MARK: - Public Interface
	public func load(url: URL) async throws -> LoadableImage {
		// Check cache first without lock
		if let cachedImage = cache.object(forKey: url as NSURL) {
			return cachedImage
		}


		// Race condition here:
		// Get or create task with mutex
		let currentActiveTask = registeredTasks.withLock { tasks in
			tasks[url]
		}

		if let currentActiveTask {
			do {
				let cachedImage = try await currentActiveTask.value
				return cachedImage
			} catch {
				print("Previously cached task for the image \(url) returned error \(error)")
			}
		}

		let newLoadingTask = registeredTasks.withLock { tasks in
			let newTask = createFetchImageTask(for: url)
			tasks[url] = newTask
			return newTask
		}

		return try await newLoadingTask.value
	}

	// MARK: - Private Helpers
	private func createFetchImageTask(for url: URL) -> Task<LoadableImage, any Error> {
		Task {
			defer {
				// remove the registered task from the local dictionary no matter what
				registeredTasks.withLock { tasks in
					tasks[url] = nil
				}
			}

			let responseData = try await apiService.getResource(url: url)
			guard let image = LoadableImage(data: responseData) else {
				throw ImageCacheError.failedDownloadingImage(url)
			}
			// put data to the cache
			cache.setObject(image, forKey: url as NSURL, cost: responseData.count)
			return image
		}
	}
}



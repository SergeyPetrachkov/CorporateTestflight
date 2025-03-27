import Foundation
import ImageLoader

protocol LoadAttachmentsUsecase: Sendable {
	func execute(attachments: [String]) async throws -> [(URL, LoadableImage)]
}

struct LoadAttachmentsUsecaseImpl: LoadAttachmentsUsecase {

	let imageLoader: ImageLoader

	// uncomment if we want to return at least something and not fail the whole group
	func execute(attachments: [String]) async throws -> [(URL, LoadableImage)] {
		try await withThrowingTaskGroup(of: (Int, URL, LoadableImage).self) { group in

			for enumeratedAttachment in attachments.enumerated() {
				guard let url = URL(string: "http://localhost:8080/images/\(enumeratedAttachment.element)") else { continue }
				group.addTask {
					//					do {
					let image = try await imageLoader.load(url: url)
					return (enumeratedAttachment.offset, url, image)
					//					}
					//					catch {
					//						print(error)
					//						return nil
					//					}
				}
			}
			var result: [(Int, URL, LoadableImage)] = []
			for try await imageResult in group {
				//				if let imageResult {
				result.append(imageResult)
				//				}
			}
			return result.sorted(by: { $0.0 < $1.0 }).map { ($0.1, $0.2) }
		}
	}
}

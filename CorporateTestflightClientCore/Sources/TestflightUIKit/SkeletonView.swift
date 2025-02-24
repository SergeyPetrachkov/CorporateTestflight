import SwiftUI

public struct SkeletonView: View {

	private let itemsCount: Int

	public init(itemsCount: Int = 7) {
		self.itemsCount = itemsCount
	}

	public var body: some View {
		List {
			ForEach(0..<itemsCount) { _ in
				VStack(alignment: .leading) {
					Text("Title")
					Text("Description here can be very long, but we don't really care, do we?")
				}
			}
		}
		.redacted(reason: .placeholder)
		.disabled(true)
	}
}

#Preview {
	SkeletonView()
}

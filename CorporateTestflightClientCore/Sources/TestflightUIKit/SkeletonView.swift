import SwiftUI

public struct SkeletonView: View {

	public init() { }

	public var body: some View {
		List {
			ForEach(0..<5) { _ in
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

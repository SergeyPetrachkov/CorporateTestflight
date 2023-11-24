//
//  ContentView.swift
//  CorporateTestflightClient
//
//  Created by Sergey Petrachkov on 18.11.2023.
//

import SwiftUI
import TestflightNetworking

final class ViewModel: ObservableObject {
    @Published var string: String = ""

    @MainActor
    func start() async throws {
        let api = TestflightAPIProvider()
        let data = try await api.getVersions(for: 1)
        string = "\(data)"
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text(viewModel.string)
        }
        .padding()
        .task {
            try? await viewModel.start()
        }
    }
}

#Preview {
    ContentView()
}

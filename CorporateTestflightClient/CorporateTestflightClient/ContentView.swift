//
//  ContentView.swift
//  CorporateTestflightClient
//
//  Created by Sergey Petrachkov on 18.11.2023.
//

import SwiftUI

final class ViewModel: ObservableObject {
    @Published var string: String = ""

    @MainActor
    func start() async throws {
        let data = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:8080/tickets")!)
        string = String(data: data.0, encoding: .utf8)!
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

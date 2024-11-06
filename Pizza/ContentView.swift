//
//  ContentView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 11. 05..
//

import SwiftUI
import Domain
import Factory

class ContentModel: ObservableObject {
    let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral

        // Allow usage of local net/IP
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 30

        return URLSession(configuration: config)
    }()
}

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var saveService = Container.shared.saveUseCase()
    @State private var showAlert = false
    @StateObject private var model = ContentModel()

    var body: some View {
        // AlertHelperView {
        //     MenuListView()
        // }
        // .onChange(of: scenePhase) { phase in
        //     if phase == .background {
        //         Task {
        //             try? await saveService.saveCart()
        //         }
        //     }
        // }
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .alert("Alert", isPresented: $showAlert) {
            Button(role: .cancel) {
                //
            } label: {
                Label("OK", systemImage: "trash")
            }
        }
        .task {
            await fetchDataFromLocalIP()
        }
    }

    func fetchDataFromLocalIP() async {
        let urlString = "http://192.168.1.20:4010/drinks"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        do {
            let (data, _) = try await model.session.data(from: url)

            // Process the data
            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    showAlert = true
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(AlertHelper())
}
#endif

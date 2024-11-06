//
//  ContentView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 04..
//

import SwiftUI
import Domain
import Factory

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var saveService = Container.shared.saveUseCase()
    @State private var showAlert = false

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
            fetchDataFromLocalIP()
        }
    }

    func fetchDataFromLocalIP() {
        let urlString = "http://192.168.1.20:4010/drinks"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data else {
                print("No data received")
                return
            }

            // Process the data
            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    showAlert = true
                }
            }
        }

        task.resume()
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(AlertHelper())
}
#endif

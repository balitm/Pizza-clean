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

    var body: some View {
        AlertHelperView {
            MenuListView()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                Task {
                    try? await saveService.saveCart()
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(AlertHelper())
}
#endif

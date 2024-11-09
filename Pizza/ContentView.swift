//
//  ContentView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 04..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import Factory

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var alertHelper: AlertHelper
    @State private var saveService = Container.shared.saveUseCase()
    @StateObject private var router = MainRouter()
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        AlertHelperView {
            MenuListView(viewModel: viewModel.menuListViewModel)
                .environmentObject(router)
        }
        .alertModifier(viewModel, alertHelper, router)
        .task {
            await viewModel.listenToReachabity()
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

private extension View {
    func alertModifier(
        _ viewModel: ContentViewModel,
        _ alertHelper: AlertHelper,
        _ router: MainRouter
    ) -> some View {
        onReceive(viewModel.alertKind) { kind in
            DLog(l: .trace, "receiving \(kind)")
            switch kind {
            case .none:
                alertHelper.hideAlert()
            case .noNetwork:
                router.popToRoot()
                alertHelper.showAlert(
                    isTouchOutside: false,
                    alignment: .top
                ) {
                    CustomNotification(text: .localizable(.noNetworkNotification))
                        .transition(.move(edge: .top))
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

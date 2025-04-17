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
    @Environment(AlertHelper.self) private var alertHelper
    @State private var cartModel = Container.shared.cartModel()
    @State private var router = MainRouter()
    @State private var viewModel = ContentViewModel()

    var body: some View {
        AlertHelperView {
            MenuListView(viewModel: viewModel.menuListViewModel)
                .environment(router)
        }
        .alertModifier(viewModel, alertHelper, router)
        .task {
            await viewModel.listenToReachabity()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .background else { return }
            Task {
                try? await cartModel.save()
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
        .environment(AlertHelper())
}
#endif

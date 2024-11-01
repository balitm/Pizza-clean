//
//  MenuListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/9/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct MenuListView: View {
    @EnvironmentObject private var alertHelper: AlertHelper
    @StateObject private var viewModel = MenuListViewModel()
    @EnvironmentObject private var router: MainRouter

    var body: some View {
        // let _ = Self._printChanges()

        NavigationStack(path: $router.path) {
            List {
                ForEach(viewModel.listData) { rowData in
                    MenuRow(data: rowData)
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                }
                Text(viewModel.appVersionInfo)
                    .frame(maxWidth: .infinity)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        router.push(.cart)
                    } label: {
                        Image(.icCartNavbar)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        router.push(.ingredients(.init()))
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.accent)
                            .fontWeight(.semibold)
                    }
                }
            }
            .animation(.default, value: viewModel.listData.isEmpty)
            .listStyle(.plain)
            .navigationDestination(for: MainPath.self) {
                router.view(for: $0)
            }
            .navigationTitle(.localizable(.mainTitle))
        }
        .alertModifier(viewModel, alertHelper, router)
        .task {
            try? await viewModel.loadPizzas()
        }
        .environmentObject(router)
    }
}

private extension View {
    func alertModifier(
        _ viewModel: MenuListViewModel,
        _ alertHelper: AlertHelper,
        _ router: MainRouter
    ) -> some View {
        onReceive(viewModel.alertKind) { kind in
            switch kind {
            case .none:
                alertHelper.hideAlert()
            case .progress:
                alertHelper.showProgress()
            case .added:
                alertHelper.showAlert(
                    isTouchOutside: true,
                    alignment: .top
                ) {
                    AddedNotification(text: .localizable(.addedNotification)) {
                        router.push(.cart)
                    }
                    .transition(.move(edge: .top))
                }
            case let .initError(error):
                alertHelper.showAlert(
                    isTouchOutside: true,
                    alignment: .bottom
                ) {
                    ErrorView(error: error) {
                        viewModel.hideAlert()
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    MenuListView()
        .environmentObject(AlertHelper())
        .environmentObject(MainRouter())
}
#endif

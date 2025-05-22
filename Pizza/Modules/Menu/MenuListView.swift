//
//  MenuListView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct MenuListView: View {
    @Bindable var store: StoreOf<MenuListFeature>

    var body: some View {
        let _ = Self._printChanges()

        WithPerceptionTracking {
            List {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                }
                ForEach(store.listData) { rowData in
                    MenuRow(
                        store: Store(
                            initialState: MenuRowFeature.State(data: rowData)
                        ) {
                            MenuRowFeature()
                        }
                    )
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                }
                // App version info can be added here if still needed,
                // possibly from a shared state or a dependency.
                // For now, focusing on core TCA conversion.
                // Text(viewModel.appVersionInfo)
                //     .frame(maxWidth: .infinity)
                //     .font(.footnote)
                //     .foregroundStyle(.secondary)
                //     .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle(String.localizable(.mainTitle))
            .task {
                await store.send(.task).finish()
            }
            // .alert(
            //     item: $store.scope(state: \.alertKind, action: \.alertDismissed)
            // ) { alertKind in
            //     switch alertKind {
            //     case .added:
            //         // The original used a custom AddedNotification.
            //         // This requires a more complex overlay or sheet if the exact style is needed.
            //         // For a standard alert:
            //         Alert(title: Text("Added to Cart!"))
            //     case .initError(let message):
            //         Alert(title: Text("Error"), message: Text(message))
            //     }
            // }
            // // Toolbar items for cart and add (+) are now managed by ContentView
            // // as they affect the global navigation stack.
            // // If MenuListView itself had local toolbar items, they'd be here.
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MenuListView(
            store: Store(
                initialState: MenuListFeature.State(
                    listData: [
                        // Preview MenuRowData needs to be created here
                        // For example:
                        // MenuRowData(index: 0, basePrice: 10.0, pizza: Pizza(name: "Preview Pizza", ingredients: [], imageUrl: nil, price: 0.0), onTapPrice: { _ in })
                    ]
                )
            ) {
                MenuListFeature()
            }
        )
    }
}
#endif

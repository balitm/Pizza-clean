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
    @Environment(AlertHelper.self) private var alertHelper
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
                ForEach(store.scope(state: \.menuRows, action: \.menuRow)) { rowStore in
                    MenuRow(store: rowStore)
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
                await store.send(.fetch).finish()
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MenuListView(
            store: Store(
                initialState: MenuListFeature.State(
                    menuRows: IdentifiedArrayOf(uniqueElements: [
                        // Preview data can be added here if needed
                    ])
                )
            ) {
                MenuListFeature()
            }
        )
    }
}
#endif

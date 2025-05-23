//
//  ContentView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 04..
//  Copyright 2024 kil-dev. All rights reserved.

import SwiftUI
import Domain
import Factory
import ComposableArchitecture

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var store: StoreOf<ContentFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                MenuListView(
                    store: store.scope(state: \.menuListState, action: \.menuList)
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            store.send(.menuList(.delegate(.navigateToCart)))
                        } label: {
                            Image(.icCartNavbar)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            //
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.accent)
                                .fontWeight(.semibold)
                        }
                    }
                }
            } destination: { store in
                switch store.case {
                case let .cart(store):
                    CartView(store: store)
                case let .drinks(store):
                    // DrinksListView(store: store) // Will need to create DrinksListView(store:)
                    EmptyView()
                case let .ingredients(store):
                    // IngredientsListView(store: store) // Will need to create IngredientsListView(store:)
                    EmptyView()
                }
            }
            .task {
                await store.send(.task).finish()
            }
            .onChange(of: scenePhase) { _, newPhase in
                store.send(.scenePhaseChanged(newPhase))
            }
            // .alert(
            //     item: $store.scope(state: \.alertKind, action: \.alertDismissed)
            // ) { alertKind in
            //     switch alertKind {
            //     case .noNetwork:
            //         Alert(title: Text("No Network"), message: Text(String.localizable(.noNetworkNotification)))
            //     }
            // }
        }
    }
}

#if DEBUG
#Preview {
    ContentView(
        store: Store(initialState: ContentFeature.State()) {
            ContentFeature()
        }
    )
}
#endif

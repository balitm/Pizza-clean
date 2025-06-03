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
    @Environment(AlertHelper.self) private var alertHelper
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var store: StoreOf<ContentFeature>

    var body: some View {
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
                DrinksListView(store: store)
            case let .ingredients(store):
                IngredientsListView(store: store)
            }
        }
        .task {
            await store.send(.task).finish()
        }
        .onChange(of: scenePhase) { _, newPhase in
            store.send(.scenePhaseChanged(newPhase))
        }
        .alertModifier(store, alertHelper)
    }
}

private extension View {
    func alertModifier(
        _ store: StoreOf<ContentFeature>,
        _ alertHelper: AlertHelper
    ) -> some View {
        onChange(of: store.alertKind) { _, kind in
            switch kind {
            case .none:
                alertHelper.hideAlert()
            case .noNetwork:
                store.send(.popToRoot)
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
    ContentView(
        store: Store(initialState: ContentFeature.State()) {
            ContentFeature()
        }
    )
}
#endif

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
    @State var store: StoreOf<ContentFeature> = Store(initialState: ContentFeature.State()) {
        ContentFeature()
    }

    var body: some View {
        WithPerceptionTracking {
            NavigationStackStore(store.scope(state: \.path, action: \.path)) {
                MenuListView(
                    store: store.scope(state: \.menuListState, action: \.menuList)
                )
                // .toolbar {
                //     ToolbarItem(placement: .navigationBarLeading) {
                //         Button {
                //             store.send(.menuList(.delegate(.navigateToCart)))
                //         } label: {
                //             Image(.icCartNavbar)
                //         }
                //     }
                //     // ToolbarItem(placement: .navigationBarTrailing) {
                //     //     Button {
                //     //         // This needs a way to select/get current pizza data if needed.
                //     //         // For now, assuming a placeholder or that MenuListFeature handles this.
                //     //         // If MenuListFeature needs to tell ContentFeature to navigate with specific data,
                //     //         // it would use a delegate action.
                //     //         // For a direct "add" button not tied to a row, it might present a sheet or new screen.
                //     //         // Let's assume for now it's a generic ingredients screen.
                //     //         // This would ideally be:
                //     //         // store.send(.menuList(.delegate(.navigateToIngredients(someData))))
                //     //         // For a generic ingredients, maybe it doesn't take data or has a default.
                //     //         // This depends on how IngredientsFeature is designed.
                //     //         // For now, I'll leave it to be triggered from MenuListFeature if it's context-specific.
                //     //         // Or, if it's a general "new custom pizza", it could be:
                //     //         // store.send(.path(.push(id: 0, .ingredients(IngredientsFeature.State()))))
                //
                //     //         // Placeholder for now - this should ideally be driven by a specific action/data
                //     //         // from MenuListFeature if it relates to *a* pizza.
                //     //         // If it's a general "add new", then it's a direct path append.
                //     //     } label: {
                //     //         Image(systemName: "plus")
                //     //             .foregroundStyle(.accent)
                //     //             .fontWeight(.semibold)
                //     //     }
                //     // }
                // }
            } destination: { store in
                switch store.state {
                case .cart:
                    if let store = store.scope(state: \.cart, action: \.cart) {
                        CartView(store: store) // Will need to create CartView(store:)
                    }
                case .drinks:
                    if let store = store.scope(state: \.drinks, action: \.drinks) {
                        DrinksListView(store: store) // Will need to create DrinksListView(store:)
                    }
                case .ingredients:
                    if let store = store.scope(state: \.ingredients, action: \.ingredients) {
                        IngredientsListView(store: store) // Will need to create IngredientsListView(store:)
                    }
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

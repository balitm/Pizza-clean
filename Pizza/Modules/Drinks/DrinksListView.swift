//
//  DrinksListView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct DrinksListView: View {
    @Environment(AlertHelper.self) private var alertHelper
    @Bindable var store: StoreOf<DrinksFeature>

    var body: some View {
        List {
            ForEach(store.listData) { item in
                Button {
                    store.send(.addToCart(index: item.index))
                } label: {
                    DrinkRow(data: item)
                }
                .listRowInsets(.init())
            }
        }
        .listStyle(.plain)
        .task {
            await store.send(.loadDrinks).finish()
        }
        .alertModifier(store, alertHelper)
        .navigationTitle(.localizable(.drinksTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

private extension View {
    func alertModifier(
        _ store: StoreOf<DrinksFeature>,
        _ alertHelper: AlertHelper
    ) -> some View {
        onChange(of: store.alertKind) { _, kind in
            switch kind {
            case .none:
                alertHelper.hideAlert()
            case .added:
                alertHelper.showAlert(
                    isTouchOutside: true,
                    alignment: .top
                ) {
                    AddedNotification(text: .localizable(.addedNotification)) {
                        store.send(.dismissView)
                    } onDismiss: {
                        store.send(.alertDismissed)
                    }
                    .transition(.move(edge: .top))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DrinksListView(
            store: Store(initialState: DrinksFeature.State()) {
                DrinksFeature()
            }
        )
    }
    .environment(AlertHelper())
}

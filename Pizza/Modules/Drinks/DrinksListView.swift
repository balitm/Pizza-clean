//
//  DrinksListView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import Factory

struct DrinksListView: View {
    @Environment(AlertHelper.self) private var alertHelper
    @Environment(\.dismiss) private var dismiss
    @InjectedObservable(\.drinksViewModel) private var viewModel

    var body: some View {
        List(viewModel.listData) { item in
            Button {
                viewModel.addToCart(index: item.index)
            } label: {
                DrinkRow(data: item)
            }
            .listRowInsets(.init())
        }
        .listStyle(.plain)
        .task {
            await viewModel.loadDrinks()
        }
        .alertModifier(viewModel, alertHelper, dismiss)
        .navigationTitle(.localizable(.drinksTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

private extension View {
    func alertModifier(
        _ viewModel: DrinksViewModel,
        _ alertHelper: AlertHelper,
        _ dismiss: DismissAction,
    ) -> some View {
        onReceive(viewModel.alertKind) { kind in
            switch kind {
            case .added:
                alertHelper.showAlert(
                    isTouchOutside: true,
                    alignment: .top
                ) {
                    AddedNotification(text: .localizable(.addedNotification)) {
                        dismiss()
                    }
                    .transition(.move(edge: .top))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DrinksListView()
    }
    .environment(AlertHelper())
}

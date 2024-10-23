//
//  DrinksListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct DrinksListView: View {
    @EnvironmentObject private var alertHelper: AlertHelper
    @EnvironmentObject private var router: MainRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DrinksViewModel()

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
        _ dismiss: DismissAction
        // _ router: MainRouter
    ) -> some View {
        onReceive(viewModel.alertKind) { kind in
            switch kind {
            case .added:
                alertHelper.showAlert(
                    isTouchOutside: true,
                    alignment: .top
                ) {
                    CustomNotification(text: .localizable(.addedNotification)) {
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
    .environmentObject(AlertHelper())
    .environmentObject(MainRouter())
}

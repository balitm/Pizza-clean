//
//  CartView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 21..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Factory

struct CartView: View {
    @Environment(AlertHelper.self) private var alertHelper
    @Environment(MainRouter.self) private var router
    @InjectedObservable(\.cartViewModel) private var viewModel

    var body: some View {
        List {
            Section {
                ForEach(viewModel.listData) { item in
                    Button {
                        viewModel.select(index: item.index)
                    } label: {
                        CartItemRow(data: item)
                    }
                }
            } header: {
                listHeader
            }
            .listRowInsets(.init())
            .listSectionSeparator(.hidden)

            Section {
                CartTotalRow(data: viewModel.totalData)
            } header: {
                listHeader
            }
            .listSectionSeparator(.hidden, edges: .bottom)
            .listRowInsets(.init())
        }
        .animation(.default, value: viewModel.listData.count)
        .environment(\.defaultMinListHeaderHeight, 0)
        .listStyle(.plain)
        .overlay(alignment: .bottom) {
            footer
        }
        .toolbar {
            Button {
                router.push(.drinks)
            } label: {
                Image(.icDrinks)
            }
        }
        .sheet(isPresented: $viewModel.showSuccess) {
            SuccessView()
        }
        .task {
            await viewModel.loadItems()
        }
        .alertModifier(viewModel, alertHelper)
        .navigationTitle(.localizable(.cartTitle))
        .toolbarRole(.editor)
        .navigationBarTitleDisplayMode(.inline)
    }

    var listHeader: some View {
        Rectangle()
            .fill(Color(.systemBackground))
            .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
    }

    var footer: some View {
        Text(localizable: .checkout)
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
            .foregroundStyle(viewModel.canCheckout ? .white : .gray)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.checkout()
            }
            .disabled(!viewModel.canCheckout)
            .background {
                Color.accent
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}

private extension View {
    func alertModifier(
        _ viewModel: CartViewModel,
        _ alertHelper: AlertHelper
    ) -> some View {
        onReceive(viewModel.alertKind) { kind in
            switch kind {
            case .none:
                alertHelper.hideAlert()
            case .progress:
                alertHelper.showProgress()
            case let .checkoutError(error):
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
    NavigationStack {
        CartView()
            .environment(AlertHelper())
            .environment(MainRouter())
    }
}
#endif

//
//  CartView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 21..
//

import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var alertHelper: AlertHelper
    @EnvironmentObject private var router: MainRouter
    @StateObject private var viewModel = CartViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    Section(header: listHeader, footer: listHeader) {
                        ForEach(viewModel.listData) { item in
                            Button {
                                viewModel.select(index: item.index)
                            } label: {
                                CartItemRow(data: item)
                                    .listRowInsets(.init())
                            }
                        }
                    }

                    Section(header: listHeader) {
                        CartTotalRow(data: viewModel.totalData)
                            .listRowInsets(.init())
                    }
                }
            }

            FooterView(viewModel: viewModel)
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
            .frame(maxWidth: .infinity, minHeight: 12, maxHeight: 12)
            .foregroundColor(Color(UIColor.systemBackground))
            .listRowInsets(.init())
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

private struct FooterView: View {
    @ObservedObject var viewModel: CartViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text(localizable: .checkout)
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                .foregroundStyle(viewModel.canCheckout ? .white : .gray)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.checkout()
                }
                .disabled(!viewModel.canCheckout)
        }
        .background {
            Color.accent
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CartView()
            .environmentObject(AlertHelper())
            .environmentObject(MainRouter())
    }
}
#endif

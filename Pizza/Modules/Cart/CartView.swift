//
//  CartView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 21..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct CartView: View {
    @Environment(AlertHelper.self) private var alertHelper
    // @Environment(MainRouter.self) private var router
    let store: StoreOf<CartFeature>

    var body: some View {
        // EmptyView()
        WithPerceptionTracking {
            List {
                Section {
                    ForEach(store.listData) { item in
                        Button {
                            store.send(.selectItem(item.index))
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
                    CartTotalRow(data: store.totalData)
                } header: {
                    listHeader
                }
                .listSectionSeparator(.hidden, edges: .bottom)
                .listRowInsets(.init())
            }
            .animation(.default, value: store.listData.count)
            .environment(\.defaultMinListHeaderHeight, 0)
            .listStyle(.plain)
            .overlay(alignment: .bottom) {
                footer
            }
            .toolbar {
                Button {
                    // router.push(.drinks)
                } label: {
                    Image(.icDrinks)
                }
            }
            // .sheet(isPresented: viewStore.binding(
            //     get: \.showSuccess,
            //     send: { $0 ? .dismissSuccess : .none }
            // )) {
            //     SuccessView()
            // }
            .task {
                await store.send(.loadItems).finish()
            }
            .alertModifier(store, alertHelper)
            .navigationTitle(.localizable(.cartTitle))
            .toolbarRole(.editor)
            .navigationBarTitleDisplayMode(.inline)
        }
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
            .foregroundStyle(store.canCheckout ? .white : .gray)
            .contentShape(Rectangle())
            .onTapGesture {
                store.send(.checkout)
            }
            .disabled(!store.canCheckout)
            .background {
                Color.accent
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}

private extension View {
    func alertModifier(
        _ store: StoreOf<CartFeature>,
        _ alertHelper: AlertHelper
    ) -> some View {
        onChange(of: store.alertKind) { _, kind in
            if let kind {
                switch kind {
                case .progress:
                    alertHelper.showProgress()
                case let .checkoutError(error):
                    alertHelper.showAlert(
                        isTouchOutside: true,
                        alignment: .bottom
                    ) {
                        EmptyView()
                        // ErrorView(error: error) {
                        //     store.send(.hideAlert)
                        // }
                        // .transition(.move(edge: .bottom))
                    }
                }
            } else {
                alertHelper.hideAlert()
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CartView(
            store: Store(
                initialState: CartFeature.State()
            ) {
                CartFeature()
            }
        )
        .environment(AlertHelper())
        .environment(MainRouter())
    }
}
#endif

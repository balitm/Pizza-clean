//
//  CartFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import Domain
import Factory

@Reducer
struct CartFeature {
    @ObservableState
    struct State: Equatable {
        var listData: [CartItemRowData] = []
        var totalData = CartTotalRowData(price: 0)
        var canCheckout = false
        var showSuccess = false
        var isLoading = false
        // var error: Error?

        var alertKind: AlertKind = .none

        enum AlertKind: Equatable {
            case none
            case progress
            case checkoutError(Error)

            static func ==(lhs: AlertKind, rhs: AlertKind) -> Bool {
                switch (lhs, rhs) {
                case (.none, .none): true
                case (.progress, .progress): true
                case let (.checkoutError(l), .checkoutError(r)): l.localizedDescription == r.localizedDescription
                default: false
                }
            }
        }
    }

    enum Action {
        case loadItems
        case itemsLoaded([CartItemRowData], CartTotalRowData, Bool)
        case checkout
        case checkoutResponse(Result<Void, Error>)
        case didSuccessDismiss
        case select(Int)
        case alert(State.AlertKind)
        case delegate(Delegate)

        enum Delegate: Equatable {
            // case dismiss
            case navigateToDrinks
            case popToRoot
        }
    }

    @Dependency(\.cartModel) var cartModel

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadItems:
                return .run { send in
                    let items = await cartModel.items()
                    let price = await cartModel.totalPrice()
                    let canCheckout = !items.isEmpty
                    let cartItemRowData = items.enumerated().map { index, item in
                        CartItemRowData(item: item, index: index)
                    }
                    let totalRowData = CartTotalRowData(price: price)
                    await send(.itemsLoaded(cartItemRowData, totalRowData, canCheckout))
                }

            case let .itemsLoaded(items, totalData, canCheckout):
                state.listData = items
                state.totalData = totalData
                state.canCheckout = canCheckout
                return .none

            case let .select(index):
                return .run { send in
                    await cartModel.remove(at: index)
                    let items = await cartModel.items()
                    let price = await cartModel.totalPrice()
                    let canCheckout = !items.isEmpty
                    let cartItemRowData = items.enumerated().map { index, item in
                        CartItemRowData(item: item, index: index)
                    }
                    let totalRowData = CartTotalRowData(price: price)
                    await send(.itemsLoaded(cartItemRowData, totalRowData, canCheckout))
                }

            case .checkout:
                state.alertKind = .progress
                return .run { send in
                    do {
                        _ = try await cartModel.checkout()
                        await send(.checkoutResponse(.success(())))
                    } catch {
                        await send(.checkoutResponse(.failure(error)))
                    }
                }

            case .checkoutResponse(.success):
                state.alertKind = .none
                state.showSuccess = true
                return .send(.loadItems)

            case let .checkoutResponse(.failure(error)):
                state.alertKind = .checkoutError(error)
                return .none

            case .didSuccessDismiss:
                state.showSuccess = false
                return .send(.delegate(.popToRoot))

            case let .alert(kind):
                state.alertKind = kind
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

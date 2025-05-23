//
//  CartFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright © 2024 kil-dev. All rights reserved.
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

        var alertKind: AlertKind? = nil

        enum AlertKind: Equatable {
            case progress
            case checkoutError(String)

            static func ==(lhs: AlertKind, rhs: AlertKind) -> Bool {
                switch (lhs, rhs) {
                case (.progress, .progress): true
                case let (.checkoutError(l), .checkoutError(r)): l == r
                default: false
                }
            }
        }
    }

    enum Action {
        case loadItems
        case itemsLoaded([CartItem])
        case totalPriceLoaded(Double)
        case selectItem(Int)
        case itemRemoved
        case checkout
        case checkoutResponse(TaskResult<Bool>)
        case hideAlert
        case dismissSuccess
        case delegate(Delegate)

        enum Delegate: Equatable {
            case dismiss
        }
    }

    @Dependency(\.cartModel) var cartModel

    var body: some Reducer<State, Action> {
        // EmptyReducer()
        Reduce { state, action in
            switch action {
            case .loadItems:
                return .run { send in
                    let items = await cartModel.items()
                    await send(.itemsLoaded(items))
                    let price = await cartModel.totalPrice()
                    await send(.totalPriceLoaded(price))
                }

            case let .itemsLoaded(items):
                state.listData = items.enumerated().map { index, item in
                    CartItemRowData(item: item, index: index)
                }
                state.canCheckout = !items.isEmpty
                return .none

            case let .totalPriceLoaded(price):
                state.totalData = CartTotalRowData(price: price)
                return .none

            case let .selectItem(index):
                return .run { send in
                    await cartModel.remove(at: index)
                    await send(.itemRemoved)
                }

            case .itemRemoved:
                return .send(.loadItems)

            case .checkout:
                state.alertKind = .progress
                return .run { send in
                    await send(.checkoutResponse(
                        TaskResult {
                            let cart = try await cartModel.checkout()
                            return cart.isEmpty
                        }
                    ))
                }

            case let .checkoutResponse(.success(success)):
                state.alertKind = nil
                if success {
                    state.showSuccess = true
                    return .send(.loadItems)
                }
                return .none

            case let .checkoutResponse(.failure(error)):
                state.alertKind = .checkoutError(error.localizedDescription)
                return .none

            case .hideAlert:
                state.alertKind = nil
                return .none

            case .dismissSuccess:
                state.showSuccess = false
                return .none

            case .delegate:
                debugPrint(#fileID, #line, "delegate has called.")
                return .none
            }
        }
    }
}

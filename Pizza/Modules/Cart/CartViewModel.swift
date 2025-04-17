//
//  CartViewModel.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import Factory

@MainActor
@Observable class CartViewModel: ViewModelBase {
    enum AlertKind {
        case progress, none, checkoutError(Error)
    }

    var showSuccess = false
    var listData = [CartItemRowData]()
    @ObservationIgnored private(set) var totalData = CartTotalRowData(price: 0)
    @ObservationIgnored private(set) var canCheckout = false
    @ObservationIgnored var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    @ObservationIgnored private let _alertKind = PassthroughSubject<AlertKind, Never>()

    @ObservationIgnored @Injected(\.cartModel) fileprivate var cartModel

    /// Load items.
    func loadItems() async {
        let items = await cartModel.items()
        canCheckout = !items.isEmpty
        let price = await cartModel.totalPrice()
        totalData = CartTotalRowData(price: price)
        listData = items.enumerated()
            .map { index, item in
                CartItemRowData(item: item, index: index)
            }
    }

    /// Buy content of the cart.
    func checkout() {
        _alertKind.send(.progress)
        Task {
            do {
                _ = try await cartModel.checkout()
                await loadItems()
                _alertKind.send(.none)
                showSuccess = true
            } catch {
                _alertKind.send(.checkoutError(error))
            }
        }
    }

    /// Remove item on tap/selected.
    func select(index: Int) {
        Task {
            await cartModel.remove(at: index)
            await loadItems()
        }
    }

    func hideAlert() {
        _alertKind.send(.none)
    }
}

// MARK: - Injection

@Observable class CartViewModelPreview: CartViewModel {
    @ObservationIgnored @Injected(\.componentsModel) private var components

    override func loadItems() async {
        // initialize
        try? await components.initialize()

        // fill up with test data
        await withDiscardingTaskGroup { group in
            for i in 0 ... 1 {
                group.addTask { [cartModel, components] in await cartModel.add(drink: components.drinks[i]) }
                group.addTask { [cartModel, components] in await cartModel.add(pizza: components.pizzas.pizzas[i]) }
            }
        }

        // publish content
        await super.loadItems()
    }
}

extension Container {
    var cartViewModel: Factory<CartViewModel> {
        self { CartViewModel() }
            .onPreview {
                CartViewModelPreview()
            }
    }
}

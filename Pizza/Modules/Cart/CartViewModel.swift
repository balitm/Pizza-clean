//
//  CartViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import Factory

@MainActor
final class CartViewModel: ViewModelBase {
    enum AlertKind {
        case progress, none, checkoutError(Error)
    }

    @Published var showSuccess = false
    @Published var listData = [CartItemRowData]()
    private(set) var totalData = CartTotalRowData(price: 0)
    private(set) var canCheckout = false
    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()

    @Injected(\.cartUseCase) private var service

    /// Load items.
    func loadItems() async {
        let items = await service.items()
        canCheckout = !items.isEmpty
        let price = await service.total()
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
                _ = try await service.checkout()
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
            await service.remove(at: index)
            await loadItems()
        }
    }

    func hideAlert() {
        _alertKind.send(.none)
    }
}

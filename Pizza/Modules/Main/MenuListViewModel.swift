//
//  MenuListViewModel.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Factory
import Combine

@MainActor
@Observable final class MenuListViewModel {
    /// UI alert events.
    enum AlertKind {
        case progress, none, added, initError(Error)
    }

    var listData = [MenuRowData]()
    @ObservationIgnored var appVersionInfo: String { model.appVersionInfo }
    @ObservationIgnored var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    @ObservationIgnored private let _alertKind = PassthroughSubject<AlertKind, Never>()

    @ObservationIgnored private var pizzas: Pizzas?
    @ObservationIgnored private(set) var isLoading = false

    @ObservationIgnored @Injected(\.menuModel) private var model

    /// Add the selected pizza to the cart.
    func addPizza(index: Int) {
        guard let pizzas else { return }

        Task {
            let pizza = pizzas.pizzas[index]
            await model.addToCart(pizza: pizza)
            _alertKind.send(.added)
        }
    }

    /// Download pizza data.
    func fetchPizzas() async throws {
        _alertKind.send(.progress)
        isLoading = true

        do {
            try await model.initialize()
            let pizzas = await model.pizzas()
            self.pizzas = pizzas

            let basePrice = pizzas.basePrice
            let vms = pizzas.pizzas.enumerated().map {
                MenuRowData(
                    index: $0.offset,
                    basePrice: basePrice,
                    pizza: $0.element,
                    onTapPrice: addPizza
                )
            }

            listData = vms
            isLoading = false
            _alertKind.send(.none)
        } catch let error as APIError {
            DLog(l: .error, "Initial donwload failed with: \(error)")
            switch error.kind {
            case .cancelled:
                // swallow cancelled error
                break
            default:
                _alertKind.send(.initError(error))
            }
        } catch {
            _alertKind.send(.initError(error))
        }
    }

    /// Reset UI when network is gone.
    func reset() {
        listData = []
        isLoading = false
    }

    /// Resume when network is back.
    func resume() {
        guard !isLoading else { return }

        Task {
            do {
                try await fetchPizzas()
            } catch {
                _alertKind.send(.initError(error))
            }
        }
    }

    func hideAlert() {
        _alertKind.send(.none)
    }
}

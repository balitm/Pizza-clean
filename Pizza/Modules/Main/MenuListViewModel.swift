//
//  MenuListViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Factory
import Combine

@MainActor
final class MenuListViewModel: ViewModelBase {
    /// UI alert events.
    enum AlertKind {
        case progress, none, added, initError(Error)
    }

    @Published var listData = [MenuRowData]()
    var appVersionInfo: String { service.appVersionInfo }
    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()

    private var pizzas: Pizzas?
    private(set) var isLoading = false

    @Injected(\.menuUseCase) private var service

    /// Add the selected pizza to the cart.
    func addPizza(index: Int) {
        guard let pizzas else { return }

        Task {
            let pizza = pizzas.pizzas[index]
            await service.addToCart(pizza: pizza)
            _alertKind.send(.added)
        }
    }

    /// Load pizza data.
    func loadPizzas() async throws {
        _alertKind.send(.progress)
        isLoading = true

        do {
            try await service.initialize()
            let pizzas = await service.pizzas()
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
                try await loadPizzas()
            } catch {
                _alertKind.send(.initError(error))
            }
        }
    }

    func hideAlert() {
        _alertKind.send(.none)
    }
}

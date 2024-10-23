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
final class MenuListViewModel: ObservableObject {
    enum AlertKind {
        case progress, none, added, initError(Error)
    }

    // Output
    @Published var listData = [MenuRowData]()
    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()

    private var pizzas: Pizzas?

    @Injected(\.menuUseCase) private var service

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

        do {
            try await service.initialize()
            let pizzas = await service.pizzas()
            self.pizzas = pizzas

            let basePrice = pizzas.basePrice
            let vms = pizzas.pizzas.enumerated().map {
                MenuRowData(index: $0.offset, basePrice: basePrice, pizza: $0.element, onTapPrice: addPizza)
            }

            listData = vms
            _alertKind.send(.none)
        } catch {
            _alertKind.send(.initError(error))
        }
    }

    func hideAlert() {
        _alertKind.send(.none)
    }
}

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

final class MenuListViewModel: ObservableObject {
    enum AlertKind {
        case progress, none, added
    }

    // Output
    @Published var listData = [MenuRowViewModel]()
    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()

    private var pizzas: Pizzas?

    @Injected(\.menuUseCase) private var service

    init() {
        DLog(">>> init: ", type(of: self))
    }

    @MainActor
    func addPizza(index: Int) {
        guard let pizzas else { return }

        Task {
            let pizza = pizzas.pizzas[index]
            await service.addToCart(pizza: pizza)
            _alertKind.send(.added)
        }
    }

    /// Load pizza data.
    @MainActor
    func loadPizzas() async throws {
        _alertKind.send(.progress)

        try await service.initialize()
        let pizzas = await service.pizzas()
        self.pizzas = pizzas

        let basePrice = pizzas.basePrice
        let vms = pizzas.pizzas.enumerated().map {
            MenuRowViewModel(index: $0.offset, basePrice: basePrice, pizza: $0.element, onTapPrice: addPizza)
        }
        DLog(l: .trace, "############## update pizza vms. #########")

        // try? await Task.sleep(nanoseconds: 3 * kSleepSecond)

        listData = vms
        _alertKind.send(.none)
    }
}

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

// import struct SwiftUI.Image

final class MenuListViewModel: ObservableObject {
    // Output
    @Published var listData = [MenuRowViewModel]()
    @Published var showAdded = false

    @Injected(\.menuUseCase) private var service

    init() {
        DLog(">>> init: ", type(of: self))

        // Buy tapped.
        // let cartEvents = $listData
        //     .map { vms in
        //         vms.map {
        //             $0.$tap
        //                 .dropFirst()
        //         }
        //     }
        //     .flatMap {
        //         Publishers.MergeMany($0)
        //     }

        // Update cart on add events.
        // cartEvents
        //     .flatMap { [cachedPizzas = _cachedPizzas] index in
        //         cachedPizzas
        //             .first()
        //             .map { (index: index, pizzas: $0) }
        //     }
        //     .flatMap { index, pizzas in
        //         service.addToCart(pizza: pizzas.pizzas[index])
        //             .catch { _ in Empty<Void, Never>() }
        //             .map { true }
        //     }
        //     .assign(to: \.showAdded, on: self)
        //     .store(in: &_bag)
    }

    /// Load pizza data.
    func loadPizzas() async throws {
        try await service.initialize()
        let pizzas = await service.pizzas()

        let basePrice = pizzas.basePrice
        let vms = pizzas.pizzas.enumerated().map {
            MenuRowViewModel(index: $0.offset, basePrice: basePrice, pizza: $0.element)
        }
        DLog(l: .trace, "############## update pizza vms. #########")
        listData = vms
    }
}

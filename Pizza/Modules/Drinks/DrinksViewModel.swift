//
//  DrinksViewModel.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import Factory

@MainActor
@Observable class DrinksViewModel: ViewModelBase {
    enum AlertKind {
        case added
    }

    var listData = [DrinkRowData]()

    @ObservationIgnored var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    @ObservationIgnored private let _alertKind = PassthroughSubject<AlertKind, Never>()

    @ObservationIgnored @Injected(\.componentsModel) var components
    @ObservationIgnored @Injected(\.cartModel) private var cartModel

    func loadDrinks() async {
        listData = await components.drinks.enumerated()
            .map {
                DrinkRowData(name: $0.element.name,
                             priceText: format(price: $0.element.price),
                             index: $0.offset)
            }
    }

    /// Add the indexed item to the cart.
    /// - Parameter index: index of the item to add.
    func addToCart(index: Int) {
        Task {
            await cartModel.add(drinkIndex: index)
            _alertKind.send(.added)
        }
    }
}

// MARK: - Injection

@Observable class DrinksViewModelPreview: DrinksViewModel {
    override func loadDrinks() async {
        try? await components.initialize()
        await super.loadDrinks()
    }
}

extension Container {
    var drinksViewModel: Factory<DrinksViewModel> {
        self { DrinksViewModel() }
            .onPreview {
                DrinksViewModelPreview()
            }
    }
}

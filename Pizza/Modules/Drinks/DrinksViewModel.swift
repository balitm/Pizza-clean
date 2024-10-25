//
//  DrinksViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import Factory

@MainActor
final class DrinksViewModel: ViewModelBase {
    enum AlertKind {
        case added
    }

    @Published var listData = [DrinkRowData]()

    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()

    @Injected(\.drinksUseCase) private var service

    func loadDrinks() async {
        listData = await service.drinks().enumerated()
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
            await service.addToCart(drinkIndex: index)
            _alertKind.send(.added)
        }
    }
}

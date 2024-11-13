//
//  IngredientsViewModel.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import Factory
import class UIKit.UIImage

private let kTimeout: TimeInterval = 3

@Observable final class IngredientsViewModel: ViewModelBase {
    /// Event to drive the buy footer of the controller.
    enum FooterEvent {
        case show(String), hide
    }

    /// UI alert events.
    enum AlertKind {
        case added
    }

    var listData = [IngredientsItemRowData]()
    var showCartText = ""
    @ObservationIgnored private(set) var title = ""

    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()
    private var timer: DispatchSourceTimer?

    @ObservationIgnored @Injected(\.ingredientsUseCase) private var service

    @MainActor
    func loadData(rowData: MenuRowData) async {
        // title
        title = rowData.pizza.name

        // items
        let selections = await service.selectedIngredients(for: rowData.pizza)
        map(selections: selections)
    }

    @MainActor
    func select(_ index: Int) {
        let selections = service.select(ingredientIndex: index)
        map(selections: selections)
        title = service.title()

        // show footer for `kTimeout` seconds
        // TODO: sketch suggest to show only ingredient prices
        //       but + cart.basePrice would be better IMHO.
        // compute price
        let sum = service.sum()
        showCartText = String(localized: .localizable(.addIngredientsToCart(format(price: sum))))
        startTimer()
    }

    @MainActor
    func addToCart() {
        Task {
            await service.addToCart()
            cancelTimer()
            _alertKind.send(.added)
        }
    }

    @MainActor
    private func map(selections: [IngredientSelection]) {
        listData = selections.enumerated().map {
            IngredientsItemRowData(
                name: $0.element.ingredient.name,
                priceText: format(price: $0.element.ingredient.price),
                isContained: $0.element.isOn,
                index: $0.offset
            )
        }
    }

    private func startTimer() {
        timer?.cancel()
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now() + kTimeout)
        timer?.setEventHandler {
            self.showCartText = ""
        }
        timer?.resume()
    }

    private func cancelTimer() {
        timer?.cancel()
        timer = nil
        self.showCartText = ""
    }
}

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

@Observable class IngredientsViewModel: ViewModelBase {
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

    @ObservationIgnored var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    @ObservationIgnored private let _alertKind = PassthroughSubject<AlertKind, Never>()
    @ObservationIgnored private var timer: DispatchSourceTimer?

    @ObservationIgnored @Injected(\.ingredientsModel) fileprivate var ingredientsModel

    @MainActor
    func loadData(rowData: MenuRowData) async {
        // title
        title = rowData.pizza.name

        // items
        let selections = await ingredientsModel.selectedIngredients(for: rowData.pizza)
        map(selections: selections)
    }

    @MainActor
    func select(_ index: Int) {
        let selections = ingredientsModel.select(at: index)
        map(selections: selections)
        title = ingredientsModel.title()

        // show footer for `kTimeout` seconds
        // TODO: sketch suggest to show only ingredient prices
        //       but + cart.basePrice would be better IMHO.
        // compute price
        let sum = ingredientsModel.totalPrice()
        showCartText = String(localized: .localizable(.addIngredientsToCart(format(price: sum))))
        startTimer()
    }

    @MainActor
    func addToCart() {
        Task {
            await ingredientsModel.addToCart()
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
        showCartText = ""
    }
}

// MARK: - Injection

extension Container {
    var ingredientsViewModel: Factory<IngredientsViewModel> {
        self { IngredientsViewModel() }
    }
}

//
//  IngredientsFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import Domain
import Factory
import Foundation

@Reducer
struct IngredientsFeature {
    @ObservableState
    struct State: Equatable {
        var pizzaData: MenuRowData
        var title: String = ""
        var listData: IdentifiedArrayOf<IngredientsItemRowData> = []
        var showCartText: String = ""
        var alertKind: AlertKind = .none
        var isTimerActive: Bool = false

        enum AlertKind: Equatable {
            case added, none

            var id: String {
                switch self {
                case .added: "added"
                case .none: "none"
                }
            }
        }

        init(pizzaData: MenuRowData) {
            self.pizzaData = pizzaData
        }
    }

    enum Action {
        case onAppear
        case selectIngredient(Int)
        case addToCart
        case loadDataResponse([IngredientSelection])
        case selectIngredientResponse([IngredientSelection], String, Double)
        case addToCartResponse
        case hideFooter
        case alert(State.AlertKind)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case navigateToCart
        }
    }

    @Dependency(\.continuousClock) var clock

    private enum CancelID { case timer }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [pizzaData = state.pizzaData] send in
                    let model = await MainActor.run { Container.shared.ingredientsModel() }
                    let selections = await model.selectedIngredients(for: pizzaData.pizza)
                    await send(.loadDataResponse(selections))
                }

            case let .selectIngredient(index):
                return .run { send in
                    let model = await MainActor.run { Container.shared.ingredientsModel() }
                    let selections = await MainActor.run {
                        model.select(at: index)
                    }
                    let title = await MainActor.run {
                        model.title()
                    }
                    let totalPrice = await MainActor.run {
                        model.totalPrice()
                    }
                    await send(.selectIngredientResponse(selections, title, totalPrice))
                }

            case .addToCart:
                return .run { send in
                    let model = await MainActor.run { Container.shared.ingredientsModel() }
                    await model.addToCart()
                    await send(.addToCartResponse)
                }

            case let .loadDataResponse(selections):
                state.title = state.pizzaData.pizza.name
                state.listData = mapSelections(selections)
                return .none

            case let .selectIngredientResponse(selections, title, totalPrice):
                state.listData = mapSelections(selections)
                state.title = title

                // Compute price and show footer
                state.showCartText = String(localized: .localizable(.addIngredientsToCart(format(price: totalPrice))))
                state.isTimerActive = true

                // Start timer to hide footer after 3 seconds
                return .concatenate(
                    .cancel(id: CancelID.timer),
                    .run { send in
                        try await clock.sleep(for: .seconds(3))
                        await send(.hideFooter)
                    }
                    .cancellable(id: CancelID.timer)
                )

            case .addToCartResponse:
                state.isTimerActive = false
                state.showCartText = ""
                return .concatenate(
                    .cancel(id: CancelID.timer),
                    .send(.alert(.added))
                )

            case .hideFooter:
                guard state.isTimerActive else { return .none }
                state.showCartText = ""
                state.isTimerActive = false
                return .none

            case let .alert(kind):
                state.alertKind = kind
                return .none

            case let .delegate(delegate):
                switch delegate {
                case .navigateToCart:
                    return .none
                }
            }
        }
    }

    private func mapSelections(_ selections: [IngredientSelection]) -> IdentifiedArrayOf<IngredientsItemRowData> {
        IdentifiedArrayOf(
            uniqueElements: selections.enumerated().map { offset, element in
                IngredientsItemRowData(
                    name: element.ingredient.name,
                    priceText: format(price: element.ingredient.price),
                    isContained: element.isOn,
                    index: offset
                )
            }
        )
    }
}

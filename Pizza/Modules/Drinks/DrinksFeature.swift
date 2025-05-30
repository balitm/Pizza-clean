//
//  DrinksFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import Domain
import Factory

@Reducer
struct DrinksFeature {
    @ObservableState
    struct State: Equatable {
        var listData: [DrinkRowData] = []
        var alertKind: AlertKind = .none

        enum AlertKind: Equatable {
            case none, added
        }
    }

    enum Action {
        case loadDrinks
        case drinksLoaded([DrinkRowData])
        case addToCart(index: Int)
        case drinkAdded
        case alertDismissed
        case dismissView
        case delegate(Delegate)

        enum Delegate: Equatable {
            case dismiss
        }
    }

    @Dependency(\.componentsModel) var componentsModel
    @Dependency(\.cartModel) var cartModel
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadDrinks:
                return .run { send in
                    let drinks = await componentsModel.drinks
                    let drinkData = drinks.enumerated().map { offset, drink in
                        DrinkRowData(
                            name: drink.name,
                            priceText: format(price: drink.price),
                            index: offset
                        )
                    }
                    await send(.drinksLoaded(drinkData))
                }

            case let .drinksLoaded(drinks):
                state.listData = drinks
                return .none

            case let .addToCart(index):
                return .run { send in
                    await cartModel.add(drinkIndex: index)
                    await send(.drinkAdded)
                }

            case .drinkAdded:
                state.alertKind = .added
                return .none

            case .alertDismissed:
                state.alertKind = .none
                return .none

            case .dismissView:
                return .run { _ in
                    await dismiss()
                }

            case .delegate:
                return .none
            }
        }
    }
}

private enum ComponentsModelKey: DependencyKey {
    static let liveValue: any Domain.ComponentsModel = Container.shared.componentsModel()
}

extension DependencyValues {
    var componentsModel: any Domain.ComponentsModel {
        get { self[ComponentsModelKey.self] }
        set { self[ComponentsModelKey.self] = newValue }
    }
}

//
//  MenuListFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import Domain
import Factory

@Reducer
struct MenuListFeature {
    @ObservableState
    struct State: Equatable {
        var listData: [MenuRowData] = []
        var isLoading: Bool = false
        var alertKind: AlertKind? = nil

        enum AlertKind: Equatable, Identifiable {
            case added, initError(String)
            var id: String {
                switch self {
                case .added: "added"
                case let .initError(msg): "error-\(msg)"
                }
            }
        }
    }

    enum Action {
        case task
        case addPizza(index: Int)
        case pizzasResponse(Result<Pizzas, Error>)
        case alertDismissed
        case lostNetwork
        case resumeNetwork
        case delegate(Delegate)

        enum Delegate: Equatable {
            case navigateToCart
            case navigateToIngredients(MenuRowData)
            case navigateToDrinks
        }
    }

    @Dependency(\.menuModel) var menuModel

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                state.alertKind = nil
                return .run { send in
                    await send(.pizzasResponse(Result { try await menuModel.fetchPizzasWithInitialisation() }))
                }

            case let .addPizza(index):
                guard state.listData.indices.contains(index) else { return .none }
                let pizza = state.listData[index].pizza
                return .run { send in
                    await menuModel.addToCart(pizza: pizza)
                    await send(.alertDismissed)
                    await send(.delegate(.navigateToCart))
                } catch: { error, send in
                    await send(.pizzasResponse(.failure(error)))
                }

            case let .pizzasResponse(.success(pizzas)):
                state.listData = pizzas.pizzas.enumerated().map {
                    MenuRowData(
                        index: $0.offset,
                        basePrice: pizzas.basePrice,
                        pizza: $0.element
                    )
                }
                state.isLoading = false
                return .none

            case let .pizzasResponse(.failure(error)):
                state.isLoading = false
                state.alertKind = .initError(error.localizedDescription)
                return .none

            case .alertDismissed:
                state.alertKind = nil
                return .none

            case .lostNetwork:
                state.listData = []
                state.isLoading = false
                state.alertKind = nil
                return .none

            case .resumeNetwork:
                if !state.isLoading && state.listData.isEmpty {
                    return .send(.task)
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Dependency

private enum MenuModelKey: DependencyKey {
    static let liveValue: any Domain.MenuModel = Container.shared.menuModel()
}

extension DependencyValues {
    var menuModel: any Domain.MenuModel {
        get { self[MenuModelKey.self] }
        set { self[MenuModelKey.self] = newValue }
    }
}

extension MenuModel {
    func fetchPizzasWithInitialisation() async throws -> Pizzas {
        try await initialize()
        return await pizzas()
    }
}

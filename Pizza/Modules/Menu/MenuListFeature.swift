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
        var isLoading: Bool = false
        var alertKind: AlertKind = .none
        var menuRows: IdentifiedArrayOf<MenuRowFeature.State> = []
        var hasLoadedOnce: Bool = false

        enum AlertKind: Equatable {
            case progress, none, added, initError(Error)

            static func ==(lhs: MenuListFeature.State.AlertKind, rhs: MenuListFeature.State.AlertKind) -> Bool {
                lhs.id == rhs.id
            }

            var id: String {
                switch self {
                case .added: "added"
                case let .initError(msg): "error-\(msg)"
                case .progress: "progress"
                case .none: "none"
                }
            }
        }
    }

    enum Action {
        case fetch
        case addPizza(Int)
        case pizzasResponse(Result<Pizzas, Error>)
        case lostNetwork
        case resumeNetwork
        case alert(State.AlertKind)
        case delegate(Delegate)
        case menuRow(IdentifiedActionOf<MenuRowFeature>)

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
            case .fetch:
                // Only load once unless explicitly cleared.
                guard !state.hasLoadedOnce else { return .none }
                state.isLoading = true
                state.alertKind = .progress
                return .run { send in
                    await send(.pizzasResponse(Result { try await menuModel.fetchPizzasWithInitialisation() }))
                }

            case let .addPizza(index):
                guard let rowState = state.menuRows[id: index] else { return .none }
                let pizza = rowState.data.pizza
                return .run { send in
                    await menuModel.addToCart(pizza: pizza)
                    await send(.alert(.added))
                } catch: { error, send in
                    await send(.pizzasResponse(.failure(error)))
                }

            case let .pizzasResponse(.success(pizzas)):
                state.alertKind = .none
                // Preserve existing images when rebuilding the menu rows
                let existingImages = Dictionary(
                    state.menuRows.map { ($0.data.index, $0.data.image) },
                    uniquingKeysWith: { first, _ in first }
                )

                state.menuRows = IdentifiedArrayOf(
                    uniqueElements: pizzas.pizzas.enumerated().map { offset, pizza in
                        var rowData = MenuRowData(
                            index: offset,
                            basePrice: pizzas.basePrice,
                            pizza: pizza
                        )
                        // Restore the existing image if available
                        rowData.image = existingImages[offset] ?? nil

                        return MenuRowFeature.State(data: rowData)
                    }
                )
                state.isLoading = false
                state.hasLoadedOnce = true
                return .none

            case let .pizzasResponse(.failure(error)):
                state.isLoading = false
                state.alertKind = .initError(error)
                return .none

            case .lostNetwork:
                state.menuRows = []
                state.isLoading = false
                state.alertKind = .none
                state.hasLoadedOnce = false
                return .none

            case .resumeNetwork:
                if !state.isLoading {
                    return .send(.fetch)
                }
                return .none

            case let .menuRow(.element(_, action: .delegate(.showDetails(rowData)))):
                return .send(.delegate(.navigateToIngredients(rowData)))

            case let .menuRow(.element(id: id, action: .delegate(.addToCart(index)))):
                assert(id == index)
                return .send(.addPizza(index))

            case .menuRow:
                return .none

            case let .alert(kind):
                state.alertKind = kind
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.menuRows, action: \.menuRow) {
            MenuRowFeature()
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

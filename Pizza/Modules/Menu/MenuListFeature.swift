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
        var alertKind: AlertKind? = nil
        var menuRows: IdentifiedArrayOf<MenuRowFeature.State> = []
        var hasLoadedOnce: Bool = false

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
        case addPizzaAtIndex(Int)
        case pizzasResponse(Result<Pizzas, Error>)
        case alertDismissed
        case lostNetwork
        case resumeNetwork
        case delegate(Delegate)
        case menuRow(IdentifiedActionOf<MenuRowFeature>)

        enum Delegate: Equatable {
            case navigateToCart
            case navigateToIngredients(MenuRowData)
            case navigateToDrinks
        }
    }

    @Dependency(\.menuModel) var menuModel

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                // Only load once unless explicitly cleared
                guard !state.hasLoadedOnce else { return .none }
                state.isLoading = true
                state.alertKind = nil
                return .run { send in
                    await send(.pizzasResponse(Result { try await menuModel.fetchPizzasWithInitialisation() }))
                }

            case let .addPizzaAtIndex(index):
                guard let rowState = state.menuRows[id: index] else { return .none }
                let pizza = rowState.data.pizza
                return .run { send in
                    await menuModel.addToCart(pizza: pizza)
                    await send(.alertDismissed)
                    await send(.delegate(.navigateToCart))
                } catch: { error, send in
                    await send(.pizzasResponse(.failure(error)))
                }

            case let .pizzasResponse(.success(pizzas)):
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
                state.alertKind = .initError(error.localizedDescription)
                return .none

            case .alertDismissed:
                state.alertKind = nil
                return .none

            case .lostNetwork:
                state.menuRows = []
                state.isLoading = false
                state.alertKind = nil
                state.hasLoadedOnce = false
                return .none

            case .resumeNetwork:
                if !state.isLoading && !state.hasLoadedOnce {
                    return .send(.task)
                }
                return .none

            case let .menuRow(.element(_, action: .delegate(.showDetails(rowData)))):
                return .send(.delegate(.navigateToIngredients(rowData)))

            case let .menuRow(.element(id: id, action: .delegate(.addToCart(index)))):
                assert(id == index)
                return .send(.addPizzaAtIndex(index))

            case .menuRow:
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

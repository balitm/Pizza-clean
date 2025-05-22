//
//  ContentFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.07.25.
//  Copyright 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import CasePaths
import Domain
import Factory
import Combine
import SwiftUI

@Reducer
struct ContentFeature {
    @Reducer(state: .equatable)
    enum Path {
        case cart(CartFeature)
        case drinks(DrinksFeature)
        case ingredients(IngredientsFeature)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var menuListState = MenuListFeature.State()
        var alertKind: RootAlertKind? = nil
        var hasNetwork: Bool = true

        enum RootAlertKind: Equatable, Identifiable {
            case noNetwork
            var id: Self { self }
        }
    }

    enum Action {
        case task
        case scenePhaseChanged(ScenePhase)
        case reachabilityUpdate(Connection)
        case alertDismissed
        case path(StackActionOf<Path>)
        case menuList(MenuListFeature.Action)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.cartModel) var cartModel
    @Dependency(\.reachability) var reachability
    @Dependency(\.menuModel) var menuModel

    var body: some Reducer<State, Action> {
        Scope(state: \.menuListState, action: \.menuList) {
            MenuListFeature()
        }

        Reduce { state, action in
            switch action {
            case .task:
                state.hasNetwork = true
                return .run { send in
                    for await connection in reachability.connection {
                        await send(.reachabilityUpdate(connection))
                    }
                }

            case let .scenePhaseChanged(phase):
                if phase == .background {
                    return .run { _ in
                        try? await cartModel.save()
                    }
                }
                return .none

            case let .reachabilityUpdate(connection):
                let hadNetworkPreviously = state.hasNetwork
                switch connection {
                case .wifi, .cellular:
                    state.hasNetwork = true
                    if !hadNetworkPreviously {
                        state.alertKind = nil
                        return .send(.menuList(.resumeNetwork))
                    }
                case .unavailable:
                    state.hasNetwork = false
                    if hadNetworkPreviously {
                        state.alertKind = .noNetwork
                        return .send(.menuList(.lostNetwork))
                    }
#if os(macOS)
                case .constrained:
                    DLog("Network is constrained.")
#endif
                @unknown default:
                    DLog("Unknown network status: \(connection)")
                }
                return .none

            case .alertDismissed:
                state.alertKind = nil
                return .none

            case .path(.element(id: _, action: .cart(.delegate(.dismiss)))):
                _ = state.path.popLast()
                return .none

            case let .menuList(.delegate(delegateAction)):
                switch delegateAction {
                case .navigateToCart:
                    state.path.append(.cart(CartFeature.State()))
                case let .navigateToIngredients(pizzaData):
                    state.path.append(.ingredients(IngredientsFeature.State(pizzaData: pizzaData)))
                case .navigateToDrinks:
                    state.path.append(.drinks(DrinksFeature.State()))
                }
                return .none

            case .menuList, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

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
    @Dependency(\.mainQueue) var mainQueue

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
                        pizza: $0.element,
                        onTapPrice: { _ in }
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

extension MenuModel {
    func fetchPizzasWithInitialisation() async throws -> Pizzas {
        try await initialize()
        return await pizzas()
    }
}

private enum MenuModelKey: DependencyKey {
    static let liveValue: any Domain.MenuModel = Container.shared.menuModel()
}

extension DependencyValues {
    var menuModel: any Domain.MenuModel {
        get { self[MenuModelKey.self] }
        set { self[MenuModelKey.self] = newValue }
    }
}

@Reducer
struct CartFeature {
    @ObservableState struct State: Equatable {}
    enum Action: Equatable { case delegate(Delegate); enum Delegate: Equatable { case dismiss } }
    var body: some Reducer<State, Action> { EmptyReducer() }
}

@Reducer
struct DrinksFeature {
    @ObservableState struct State: Equatable {}
    enum Action: Equatable {}
    var body: some Reducer<State, Action> { EmptyReducer() }
}

@Reducer
struct IngredientsFeature {
    @ObservableState struct State: Equatable {
        var pizzaData: MenuRowData? = nil
    }

    enum Action: Equatable {}
    var body: some Reducer<State, Action> { EmptyReducer() }
}

private enum CartModelKey: DependencyKey {
    static let liveValue: any Domain.CartModel = Container.shared.cartModel()
    static let testValue: any Domain.CartModel = UnimplementedCartModel()
}

extension DependencyValues {
    var cartModel: any Domain.CartModel {
        get { self[CartModelKey.self] }
        set { self[CartModelKey.self] = newValue }
    }
}

private enum ReachabilityDependencyKey: DependencyKey {
    static let liveValue: any Domain.ReachabilityModel = Container.shared.reachability()
}

extension DependencyValues {
    var reachability: any Domain.ReachabilityModel {
        get { self[ReachabilityDependencyKey.self] }
        set { self[ReachabilityDependencyKey.self] = newValue }
    }
}

actor UnimplementedCartModel: Domain.CartModel {
    var cart: Domain.Cart = .init(pizzas: [], drinks: [], basePrice: 0.0)

    func initialize() async throws -> Domain.Cart { fatalError() }
    func start(with _: Domain.Cart) -> Domain.Cart { fatalError() }
    func add(pizza _: Domain.Pizza) -> Domain.Cart { fatalError() }
    func add(pizzaIndex _: Int) async -> Domain.Cart { fatalError() }
    func add(drink _: Domain.Drink) -> Domain.Cart { fatalError() }
    func add(drinkIndex _: Int) async -> Domain.Cart { fatalError() }
    func remove(at _: Int) -> Domain.Cart { fatalError() }
    func items() -> [Domain.CartItem] { fatalError() }
    func totalPrice() -> Double { fatalError() }
    func empty() throws -> Domain.Cart { fatalError() }
    func save() throws { fatalError() }
    func checkout() async throws -> Domain.Cart { fatalError() }
}

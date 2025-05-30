//
//  ContentFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import Domain
import Factory
import enum SwiftUI.ScenePhase

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
        var alertKind: AlertKind = .none
        var hasNetwork: Bool = true

        enum AlertKind: Equatable {
            case none, noNetwork
        }
    }

    enum Action {
        case task
        case scenePhaseChanged(ScenePhase)
        case reachabilityUpdate(Connection)
        case alert(State.AlertKind)
        case popToRoot
        case path(StackActionOf<Path>)
        case menuList(MenuListFeature.Action)
    }

    @Dependency(\.cartModel) var cartModel
    @Dependency(\.reachability) var reachability

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
                        state.alertKind = .none
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

            case let .alert(kind):
                state.alertKind = kind
                return .none

            case .popToRoot:
                state.path.removeAll()
                return .none

            case .path(.element(id: _, action: .cart(.delegate(.popToRoot)))):
                state.path.removeAll()
                return .none

            case .path(.element(id: _, action: .cart(.delegate(.navigateToDrinks)))):
                state.path.append(.drinks(DrinksFeature.State()))
                return .none

            case let .menuList(.delegate(delegateAction)):
                switch delegateAction {
                case .navigateToCart:
                    state.path.append(.cart(CartFeature.State()))
                case let .navigateToIngredients(pizzaData):
                    state.path.append(.ingredients(IngredientsFeature.State(pizzaData: pizzaData)))
                }
                return .none

            case .menuList, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
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

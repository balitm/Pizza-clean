//
//  Initializer.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/12/20.
//

import Foundation
import Domain
import DataSource
import Combine

final class Initializer {
    struct Components {
        let pizzas: Pizzas
        let ingredients: [Ingredient]
        let drinks: [Drink]

        static let empty = Components(pizzas: Pizzas(pizzas: [], basePrice: 0), ingredients: [], drinks: [])
    }

    typealias ComponentsResult = Result<Components, APIError>

    let container: DataSource.Container?
    let network: NetworkProtocol

    @Published var component: ComponentsResult = .failure(APIError(kind: .disabled))
    let cartHandler: CartHandler

    private var _bag = Set<AnyCancellable>()

    deinit {
        DLog("Initializer deinited.")
    }

    init(container: DataSource.Container?, network: NetworkProtocol) {
        self.container = container
        self.network = network
        cartHandler = CartHandler(container: container)

        _bag = [
            // Get components.
            Publishers.Zip3(network.getPizzas(),
                            network.getIngredients(),
                            network.getDrinks())
                .map { (tuple: (pizzas: DataSource.Pizzas, ingredients: [DataSource.Ingredient], drinks: [DataSource.Drink])) -> ComponentsResult in
                    let ingredients = tuple.ingredients.sorted { $0.name < $1.name }

                    let components = Components(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                                ingredients: ingredients,
                                                drinks: tuple.drinks)
                    return .success(components)
                }
                .catch {
                    Just(ComponentsResult.failure($0))
                }
                .assign(to: \.component, on: self),
        ]

        // Init card.
        $component
            .compactMap { try? $0.get() }
            .first()
            .receive(on: DataSource.dbQueue)
            .setFailureType(to: Error.self)
            .map { [weak container] c -> CartAction in
                // DLog("###### init cart. #########")
                let dsCart = container?.values(DataSource.Cart.self).first ?? DataSource.Cart(pizzas: [], drinks: [])
                var cart = dsCart.asDomain(with: c.ingredients, drinks: c.drinks)
                cart.basePrice = c.pizzas.basePrice
                return CartAction.start(with: cart)
            }
            .catch { _ in Empty<CartAction, Never>() }
            .subscribe(cartHandler.input)
    }
}

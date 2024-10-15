//
//  InitRepository.swift
//  Repository
//
//  Created by Balázs Kilvády on 2024. 10. 14..
//

import Foundation
import Domain
import DataSource
import Factory

actor InitRepository {
    struct Components {
        let pizzas: Pizzas
        let ingredients: [Ingredient]
        let drinks: [Drink]

        static let empty = Components(pizzas: Pizzas(pizzas: [], basePrice: 0), ingredients: [], drinks: [])
    }

    @Injected(\.pizzaAPI) var network
    @Injected(\.storage) var storage

    private(set) var component = Components.empty
    let cartHandler = CartHandler()

    func initialize() async throws -> Components {
        let component = try await self.initComponentes()
        self.component = component

        // Init cart.
        // DLog("###### init cart. #########")
        let dsCart = storage.values(DataSource.Cart.self).first ?? DataSource.Cart(pizzas: [], drinks: [])
        var cart = dsCart.asDomain(with: component.ingredients, drinks: component.drinks)
        cart.basePrice = component.pizzas.basePrice
        _ = await self.cartHandler.start(with: cart)
        return component
    }

    private func initComponentes() async throws -> Components {
        async let pizzas = network.getPizzas()
        async let ingredients = network.getIngredients()
        async let drinks = network.getDrinks()

        do {
            let tuple = try await (pizzas: pizzas, ingredients: ingredients, drinks: drinks)
            let ingredients = tuple.ingredients.sorted { $0.name < $1.name }

            let components = Components(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                        ingredients: ingredients,
                                        drinks: tuple.drinks)
            return components
        } catch let error as APIError {
            DLog(l: .error, "Initial donwload failed with: \(error)")
            throw error
        } catch {
            DLog(l: .error, "Initial donwload failed with: \(error)")
            throw APIError(kind: .invalidResponse, message: error.localizedDescription)
        }
    }

}

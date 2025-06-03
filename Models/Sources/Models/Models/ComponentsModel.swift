//
//  ComponentsModel.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 10..
//

import Foundation
import Domain
import DataSource
import Factory

actor ComponentsModel: Domain.ComponentsModel {
    public private(set) var pizzas: Pizzas
    public private(set) var ingredients: [Ingredient]
    public private(set) var drinks: [Drink]

    static let empty = ComponentsModel()

    init() {
        pizzas = Pizzas(pizzas: [], basePrice: 0)
        ingredients = []
        drinks = []
    }

    public func initialize() async throws {
        let network = DataSourceContainer.shared.pizzaAPI()

        async let pizzas = network.getPizzas()
        async let ingredients = network.getIngredients()
        async let drinks = network.getDrinks()

        do {
            let tuple = try await (pizzas: pizzas, ingredients: ingredients, drinks: drinks)
            let ingredients = tuple.ingredients.sorted { $0.name < $1.name }

            self.pizzas = tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks)
            self.ingredients = ingredients
            self.drinks = tuple.drinks
        } catch let error as APIError {
            DLog(l: .error, "Initial donwload failed with: \(error)")
            throw error
        } catch {
            DLog(l: .error, "Initial donwload failed with: \(error)")
            throw APIError(kind: .invalidResponse, message: error.localizedDescription)
        }
    }
}

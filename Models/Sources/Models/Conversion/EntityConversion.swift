//
//  EntityConversion.swift
//  Repository
//
//  Created by Balázs Kilvády on 2024. 10. 12..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import DataSource

extension DataSource.Drink: DomainConvertibleType {
    func asDomain(with _: [DataSource.Ingredient], drinks: [DataSource.Drink]) -> Domain.Drink {
        drinks.first { $0.id == id } ?? Domain.Drink(id: -1, name: "", price: 0)
    }
}

extension DataSource.Pizza: DomainConvertibleType {
    func asDomain(with ingredients: [DataSource.Ingredient], drinks _: [DataSource.Drink]) -> Domain.Pizza {
        let related = self.ingredients.compactMap { id in
            ingredients.first(where: { $0.id == id })
        }
        let imageURL: URL? = {
            guard let str = imageUrl else { return nil }
            return URL(string: str)
        }()
        return Domain.Pizza(name: name, ingredients: related, imageUrl: imageURL)
    }
}

extension Domain.Pizza: DataSourceRepresentable {
    func asDataSource() -> DataSource.Pizza {
        DataSource.Pizza(name: name,
                         ingredients: ingredients.map(\.id),
                         imageUrl: imageUrl?.absoluteString)
    }
}

extension DataSource.Pizzas: DomainConvertibleType {
    func asDomain(with ingredients: [Ingredient], drinks: [DataSource.Drink]) -> Domain.Pizzas {
        let dPizzas = pizzas.map { pizza -> Domain.Pizza in
            pizza.asDomain(with: ingredients, drinks: drinks)
        }
        return Domain.Pizzas(pizzas: dPizzas, basePrice: basePrice)
    }
}

extension Domain.Pizzas: DataSourceRepresentable {
    func asDataSource() -> DataSource.Pizzas {
        DataSource.Pizzas(pizzas: pizzas.map { $0.asDataSource() }
                          , basePrice: basePrice)
    }
}

extension DataSource.Cart: DomainConvertibleType {
    func asDomain(with ingredients: [DataSource.Ingredient], drinks: [DataSource.Drink]) -> Domain.Cart {
        let related = self.drinks.compactMap { id in
            drinks.first(where: { $0.id == id })
        }
        return Domain.Cart(
            pizzas: pizzas.map { $0.asDomain(with: ingredients, drinks: drinks) },
            drinks: related,
            basePrice: 0.0)
    }
}

extension Domain.Cart: DataSourceRepresentable {
    func asDataSource() -> DataSource.Cart {
        DataSource.Cart(pizzas: pizzas.map { $0.asDataSource() },
                        drinks: drinks.map(\.id))
    }
}

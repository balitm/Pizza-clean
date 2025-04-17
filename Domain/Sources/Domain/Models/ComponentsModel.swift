//
//  ComponentsModel.swift
//  Domain
//
//  Created by Balázs Kilvády on 2025. 04. 10..
//

public protocol ComponentsModel: Actor {
    var pizzas: Pizzas { get }
    var ingredients: [Ingredient] { get }
    var drinks: [Drink] { get }

    func initialize() async throws
}

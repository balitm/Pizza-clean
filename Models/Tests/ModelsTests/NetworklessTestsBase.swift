//
//  NetworklessTestsBase.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 10..
//

import Testing
import RealmSwift
import Domain
import Factory
@testable import Models

class NetworklessTestsBase {
    var cartModel: Models.CartModel!
    var component: Domain.ComponentsModel!

    init() async throws {
        component = Container.shared.componentsModel()
        try await component.initialize()
        cartModel = Container.shared.cartModel() as? Models.CartModel
        _ = try await cartModel.initialize()
    }

    func addItemTest(
        addItem: @escaping @Sendable () async throws -> Void,
        test: @escaping (Cart) async throws -> Void = { #expect($0.pizzas.count >= 1) }
    ) async throws {
        // Empty the cart.
        _ = try await cartModel.empty()
        await #expect(cartModel.cart.pizzas.isEmpty)
        await #expect(cartModel.cart.drinks.isEmpty)

        // Add item.
        try await addItem()

        // test
        try await test(cartModel.cart)
    }
}

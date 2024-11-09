//
//  NetworklessUseCaseTestsBase.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/20/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Testing
import RealmSwift
import Domain
import Factory
@testable import Repository

class NetworklessUseCaseTestsBase: UseCaseTestsBase {
    var data: InitRepository!
    var component: InitRepository.Components!

    override init() async throws {
        try await super.init()

        data = Container.shared.initActor()
        component = try await data.initialize()
    }

    func addItemTest(
        addItem: @escaping () async throws -> Void,
        test: @escaping (Cart) async throws -> Void = { #expect($0.pizzas.count >= 1) }
    ) async throws {
        // Empty the cart.
        _ = try await data.cartHandler.empty()
        await #expect(data.cartHandler.cart.pizzas.isEmpty)
        await #expect(data.cartHandler.cart.drinks.isEmpty)

        // Add item.
        try await addItem()

        // test
        try await test(data.cartHandler.cart)
    }
}

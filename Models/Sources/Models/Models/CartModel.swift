//
//  CartModel.swift
//  Domain
//
//  Created by Balázs Kilvády on 03/25/21.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import DataSource
import Factory

actor CartModel {
    @Injected(\DataSourceContainer.storage) private var storage
    private(set) var cart = Cart.empty

    func start(with: Cart) -> Cart {
        cart = with
        return cart
    }

    func add(pizza: Pizza) -> Cart {
        cart.add(pizza: pizza)
        return cart
    }

    func add(drink: Drink) -> Cart {
        cart.add(drink: drink)
        return cart
    }

    func remove(index: Int) -> Cart {
        cart.remove(at: index)
        return cart
    }

    func empty() throws -> Cart {
        var cart = cart
        cart.empty()
        try _dbAction(storage)
        self.cart = cart
        return cart
    }

    func save() throws {
        try _dbAction(storage) {
            $0.add(cart.asDataSource())
        }
    }
}

private func _dbAction(_ container: DataSource.Storage,
                       _ operation: (DataSource.WriteTransaction) -> Void = { _ in }) throws {
    try DataSource.dbQueue.sync {
        try container.write {
            $0.delete(DataSource.Pizza.self)
            $0.delete(DataSource.Cart.self)
            operation($0)
        }
    }
}

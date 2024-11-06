//
//  DatabaseTest.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 11..
//

import Testing
import RealmSwift
import Factory
@testable import DataSource

struct DatabaseTest {
    nonisolated(unsafe) static let realm: Realm = {
        var config = Realm.Configuration.defaultConfiguration
        debugPrint(#fileID, #line, "Realm file: \(config.fileURL!.path)")
        var fileURL = config.fileURL!
        fileURL.deleteLastPathComponent()
        fileURL.deleteLastPathComponent()
        fileURL.appendPathComponent("tmp")
        fileURL.appendPathComponent("test.realm")
        debugPrint(#fileID, #line, "Realm file: \(fileURL.path)")
        config.fileURL = fileURL

        do {
            nonisolated(unsafe) var realm: Realm!
            try DS.dbQueue.sync {
                realm = try Realm(configuration: config, queue: DS.dbQueue)
                _ = Container.shared.storage.register {
                    DS.Storage(realm: realm)
                }
            }
            debugPrint(#fileID, #line, "!!! test sequence init")

            return realm
        } catch {
            fatalError("test realm can't be inited:\n\(error)")
        }
    }()

    let container: DS.Storage
    let mock: PizzaNetwork

    init() async throws {
        container = DS.Storage(realm: Self.realm)
        mock = Container.shared.pizzaAPI()
        debugPrint(#fileID, #line, "!!! test case init")
    }

    @Test func save() async throws {
        let drinks = try! await mock.getDrinks()
        debugPrint(#fileID, #line, drinks)
        #expect(!drinks.isEmpty)

        let pizzas = try! await mock.getPizzas()
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)

        let cart = DS.Cart(
            pizzas: Array(pizzas.pizzas.prefix(2)),
            drinks: Array(drinks.prefix(2).map(\.id))
        )

        let error = dbAction(container) {
            $0.add(cart)
        }
        #expect(error == nil)

        DS.dbQueue.sync {
            do {
                let carts = container.values(DS.Cart.self)
                #expect(carts.count == 1)
                let cart = carts.first!
                #expect(cart.pizzas.count == 2)
                #expect(cart.drinks.count == 2)
                for drink in cart.drinks.enumerated() {
                    #expect(drink.element == drinks[drink.offset].id)
                }
                for pizza in cart.pizzas.enumerated() {
                    #expect(pizza.element.name == pizzas.pizzas[pizza.offset].name)
                }
                try container.write {
                    $0.delete(DS.Pizza.self)
                    $0.delete(DS.Cart.self)
                }
            } catch {
                Issue.record("Database threw \(error)")
            }
        }
    }
}

private func dbAction(
    _ container: DS.Storage?,
    _ operation: (DS.WriteTransaction) -> Void = { _ in }
) -> Error? {
    do {
        try DS.dbQueue.sync {
            try container?.write {
                $0.delete(DS.Pizza.self)
                $0.delete(DS.Cart.self)
                operation($0)
            }
        }
        return nil
    } catch {
        return error
    }
}

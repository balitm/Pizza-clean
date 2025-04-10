//
//  CartModel.swift
//  Domain
//
//  Created by Balázs Kilvády on 2025. 04. 10..
//

import Foundation

public protocol CartModel: Actor {
    var cart: Cart { get }

    @discardableResult func initialize() async throws -> Cart
    @discardableResult func add(pizza: Pizza) -> Cart
    @discardableResult func add(pizzaIndex: Int) async -> Cart
    @discardableResult func add(drink: Drink) -> Cart
    @discardableResult func add(drinkIndex: Int) async -> Cart
    @discardableResult func remove(at index: Int) -> Cart
    func items() -> [CartItem]
    func totalPrice() -> Double
    @discardableResult func empty() throws -> Cart
    func save() throws
    @discardableResult func checkout() async throws -> Cart
}

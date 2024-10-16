//
//  DSCheckout.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 08..
//

struct CheckoutRequest: Encodable {
    let pizzas: [DS.Pizza]
    let drinks: [DS.Drink.ID]
}

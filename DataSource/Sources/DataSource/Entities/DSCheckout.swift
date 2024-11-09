//
//  DSCheckout.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 08..
//  Copyright © 2024 kil-dev. All rights reserved.
//

struct CheckoutRequest: Encodable {
    let pizzas: [DS.Pizza]
    let drinks: [DS.Drink.ID]
}

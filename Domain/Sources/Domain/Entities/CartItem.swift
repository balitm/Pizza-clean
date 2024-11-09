//
//  CartItem.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public struct CartItem: Sendable {
    public let name: String
    public let price: Double
    public let id: Int

    public init(name: String, price: Double, id: Int) {
        self.name = name
        self.price = price
        self.id = id
    }
}

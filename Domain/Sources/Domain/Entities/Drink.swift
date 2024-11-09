//
//  Drink.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public struct Drink: Sendable, Codable {
    public typealias ID = Int64

    public let id: ID
    public let name: String
    public let price: Double

    public init(id: ID, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
}

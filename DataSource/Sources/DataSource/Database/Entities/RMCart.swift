//
//  RMCart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import RealmSwift

public final class RMCart: Object {
    @Persisted var pizzas = List<RMPizza>()
    @Persisted var drinks = List<Int64>()
}

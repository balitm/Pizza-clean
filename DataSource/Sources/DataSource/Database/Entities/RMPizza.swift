//
//  RMPizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import RealmSwift

public final class RMPizza: Object {
    @Persisted var name = ""
    let ingredients = List<Int64>()
    @Persisted var imageUrl = ""
}

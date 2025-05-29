//
//  DrinkRowData.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

struct DrinkRowData {
    let name: String
    let priceText: String
    let index: Int
}

extension DrinkRowData: Identifiable, Equatable {
    var id: Int { index }
}

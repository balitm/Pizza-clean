//
//  DrinkRowData.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

struct DrinkRowData {
    let name: String
    let priceText: String
    let index: Int
}

extension DrinkRowData: Identifiable {
    var id: Int { index }
}

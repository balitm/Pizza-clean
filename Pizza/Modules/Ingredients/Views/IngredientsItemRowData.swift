//
//  IngredientsItemRowData.swift
//  Pizza
//
//  Created by Balázs Kilvády on 6/21/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

struct IngredientsItemRowData {
    let name: String
    let priceText: String
    let isContained: Bool
    let index: Int
}

extension IngredientsItemRowData: Identifiable {
    var id: Int { index }
}

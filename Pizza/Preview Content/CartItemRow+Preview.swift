//
//  CartItemRow+Preview.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 23..
//

import Foundation
import Domain

extension CartItemRowData {
    static var preview: Self {
        Self(
            item: CartItem(name: "Name", price: 5.0, id: 0),
            index: 0
        )
    }
}

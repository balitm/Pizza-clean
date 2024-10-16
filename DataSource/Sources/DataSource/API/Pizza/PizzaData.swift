//
//  PizzaData.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 10..
//

#if DEBUG
import Foundation

enum PizzaData {
    static let drinks: [DS.Drink] = load(_kDrinks)
    static let ingredients: [DS.Ingredient] = load(_kIngredients)
    static let pizzas: DS.Pizzas = load(_kPizzas)
}

func load<T: Decodable>(_ jsonStr: String) -> T {
    do {
        let jsonData = jsonStr.data(using: .utf8)!
        let decoder = JSONDecoder()
        let object = try decoder.decode(T.self, from: jsonData)
        return object
    } catch {
        fatalError(">>> decode error: \(jsonStr)\n\(error)")
    }
}

private let _kDrinks = """
[
    {
        "id": 1,
        "name": "Still Water",
        "price": 1
    },
    {
        "id": 2,
        "name": "Sparkling Water",
        "price": 1.5
    },
    {
        "id": 3,
        "name": "Coke",
        "price": 2.5
    },
    {
        "id": 4,
        "name": "Beer",
        "price": 3
    },
    {
        "id": 5,
        "name": "Red Wine",
        "price": 4
    }
]
"""

private let _kIngredients = """
[
    {
        "id": 1,
        "name": "Mozzarella",
        "price": 1
    },
    {
        "id": 2,
        "name": "Tomato Sauce",
        "price": 0.5
    },
    {
        "id": 3,
        "name": "Salami",
        "price": 1.5
    },
    {
        "id": 4,
        "name": "Mushrooms",
        "price": 2
    },
    {
        "id": 5,
        "name": "Ricci",
        "price": 4
    },
    {
        "id": 6,
        "name": "Asparagus",
        "price": 2
    },
    {
        "id": 7,
        "name": "Pineapple",
        "price": 1
    },
    {
        "id": 8,
        "name": "Speck",
        "price": 3
    },
    {
        "id": 9,
        "name": "Bottarga",
        "price": 2.5
    },
    {
        "id": 10,
        "name": "Tuna",
        "price": 2.2
    }
]
"""

private let _kPizzas = """
{
  "basePrice": 4,
  "pizzas": [
    {
      "name": "Margherita",
      "ingredients": [
        1,
        2
      ],
      "imageUrl": "https://seafile.arteries.hu/f/72e67aa8b2784333a15d/?dl=1"
    },
    {
      "name": "Ricci",
      "ingredients": [
        1,
        5
      ],
      "imageUrl": "https://seafile.arteries.hu/f/0a8b5ae87d4844418c16/?dl=1"
    },
    {
      "name": "Boscaiola",
      "ingredients": [
        1,
        2,
        3,
        4
      ],
      "imageUrl": "https://seafile.arteries.hu/f/890735e82ee24483ade3/?dl=1"
    },
    {
      "name": "Primavera",
      "ingredients": [
        1,
        5,
        6
      ],
      "imageUrl": "https://seafile.arteries.hu/f/d2fb80d3eae14336b9a4/?dl=1"
    },
    {
      "name": "Hawaii",
      "ingredients": [
        1,
        2,
        7,
        8
      ],
      "imageUrl": "https://seafile.arteries.hu/f/e74891428f7443b39a6e/?dl=1"
    },
    {
      "name": "Mare Bianco",
      "ingredients": [
        1,
        9,
        10
      ]
    },
    {
      "name": "Mari e monti",
      "ingredients": [
        1,
        2,
        4,
        8,
        9,
        10
      ],
      "imageUrl": "https://seafile.arteries.hu/f/f5e317c08b294eaaa456/?dl=1"
    },
    {
      "name": "Bottarga",
      "ingredients": [
        1,
        9
      ],
      "imageUrl": "https://seafile.arteries.hu/f/d373b0a798fc4cc096c0/?dl=1"
    },
    {
      "name": "Boottarga e Asparagi",
      "ingredients": [
        1,
        2,
        9,
        6
      ],
      "imageUrl": "https://seafile.arteries.hu/f/f5a11cdaa00b4a32ba1c/?dl=1"
    },
    {
      "name": "Ricci e Asparagi",
      "ingredients": [
        1,
        5,
        6
      ],
      "imageUrl": "https://seafile.arteries.hu/f/fe4922a18bc94b0d9405/?dl=1"
    }
  ]
}
"""

#endif

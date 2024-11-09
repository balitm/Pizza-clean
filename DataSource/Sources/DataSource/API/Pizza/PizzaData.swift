//
//  PizzaData.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 10..
//  Copyright © 2024 kil-dev. All rights reserved.
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
      "imageUrl": "https://drive.google.com/uc?export=download&id=1SeX23_JZ5JsgqcVXqyyyKbBlb8IkP50D"
    },
    {
      "name": "Ricci",
      "ingredients": [
        1,
        5
      ],
      "imageUrl": "https://drive.google.com/uc?export=download&id=14D7zR82oywZbEKZYXg6LehLhqddNK07D"
    },
    {
      "name": "Boscaiola",
      "ingredients": [
        1,
        2,
        3,
        4
      ],
      "imageUrl": "https://drive.google.com/uc?export=download&id=1n_yyc55nEVwoOPO3bHQgqrbJP79iVqaA"
    },
    {
      "name": "Primavera",
      "ingredients": [
        1,
        5,
        6
      ],
      "imageUrl": "https://drive.google.com/uc?export=download&id=1WYcpmXtz4CZnSVxByW2vjSLNpxN1q0jL"
    },
    {
      "name": "Hawaii",
      "ingredients": [
        1,
        2,
        7,
        8
      ],
      "imageUrl": "https://drive.google.com/uc?export=download&id=1hPJNswxRSDudT5wsmPh6VQkJGIa6_Lv1"
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
      "imageUrl": "https://drive.google.com/uc?export=download&id=1dz-zx45_9H74OqT-_bd0tSIHu3TPXnk-"
    },
    {
      "name": "Bottarga",
      "ingredients": [
        1,
        9
      ],
      "imageUrl": "https://drive.google.com/uc?export=download&id=1CvwuqO2V0I7IKjLeMq4IGwKZlZAjpMYb"
    },
    {
      "name": "Boottarga e Asparagi",
      "ingredients": [
        1,
        2,
        9,
        6
      ],
      "imageUrl": "https://drive.google.com/uc?export=download&id=13scUPhjIIhXOZ4yaLE9lsShi_jPygXPO"
    },
    {
      "name": "Ricci e Asparagi",
      "ingredients": [
        1,
        5,
        6
      ],
      "imageUrl": "https://drive.google.com/uc?export=download&id=16480rKx_X-POxY-OWcVUB6-iBE4YD2mD"
    }
  ]
}
"""

#endif

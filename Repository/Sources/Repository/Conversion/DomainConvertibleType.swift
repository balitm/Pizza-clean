//
//  DomainConvertibleType.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import DataSource

protocol DomainConvertibleType {
    associatedtype DomainType

    func asDomain(with ingredients: [DataSource.Ingredient], drinks: [DataSource.Drink]) -> DomainType
}

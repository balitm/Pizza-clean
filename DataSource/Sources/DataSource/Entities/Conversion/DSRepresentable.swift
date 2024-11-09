//
//  DSRepresentable.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

protocol DSRepresentable {
    associatedtype DSType: DomainConvertibleType

    func asDataSource() -> DSType
}

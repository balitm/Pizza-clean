//
//  CartUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Combine

public protocol CartUseCase {
    func items() async -> [CartItem]
    func total() async -> Double
    func remove(at index: Int) async
    func checkout() async throws -> Cart
}

//
//  SaveUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public protocol SaveUseCase {
    func saveCart() async throws
}

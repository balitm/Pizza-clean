//
//  SaveRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Factory

struct SaveRepository: SaveUseCase {
    @Injected(\.initActor) private var initActor

    func saveCart() async throws {
        _ = try await initActor.cartHandler.save()
    }
}

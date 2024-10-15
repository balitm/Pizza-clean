//
//  SaveUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//

import Foundation

public protocol SaveUseCase {
    func saveCart() async throws
}

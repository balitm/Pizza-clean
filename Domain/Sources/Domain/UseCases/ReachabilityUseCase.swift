//
//  ReachabilityUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2024. 11. 01..
//

import Foundation

public protocol ReachabilityUseCase {
    var connection: AsyncStream<Connection> { get }
}

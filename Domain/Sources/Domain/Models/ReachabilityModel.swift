//
//  ReachabilityModel.swift
//  Domain
//
//  Created by Balázs Kilvády on 2024. 11. 01..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public protocol ReachabilityModel: Sendable {
    var connection: AsyncStream<Connection> { get }

    /// Reset (underlying URL)session.
    func resetSession() async
}

//
//  AppFlavour.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 17..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public enum AppFlavour: String, Codable, Sendable {
    case production
    case `internal`
    case develompent
    case testing // no xcconfig; used in package testing
}

//
//  AppFlavour.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 17..
//

import Foundation

public enum AppFlavour: String, Codable, Sendable {
    case production
    case `internal`
    case develompent
    case testing // no xcconfig; used in package testing
}

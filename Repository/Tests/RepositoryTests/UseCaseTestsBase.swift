//
//  UseCaseTestsBase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Testing
import RealmSwift
import Domain
import DataSource
import Factory
@testable import Repository

typealias DS = DataSource

class UseCaseTestsBase {
    static let inited: Bool = {
        var config = Realm.Configuration.defaultConfiguration
        debugPrint(#fileID, #line, "Realm file: \(config.fileURL!.path)")
        var fileURL = config.fileURL!
        fileURL.deleteLastPathComponent()
        fileURL.deleteLastPathComponent()
        fileURL.appendPathComponent("tmp")
        fileURL.appendPathComponent("test.realm")
        debugPrint(#fileID, #line, "Realm file: \(fileURL.path)")
        config.fileURL = fileURL

        do {
            nonisolated(unsafe) var realm: Realm!
            try DS.dbQueue.sync {
                realm = try Realm(configuration: config, queue: DS.dbQueue)
                _ = DataSourceContainer.shared.storage.register {
                    DS.Storage(realm: realm)
                }
            }
            debugPrint(#fileID, #line, "!!! test sequence init")

            return true
        } catch {
            fatalError("test realm can't be inited:\n\(error)")
        }
    }()

    let storage: DS.Storage
    let mock: PizzaNetwork

    init() async throws {
        _ = Self.inited
        storage = DataSourceContainer.shared.storage()
        mock = DataSourceContainer.shared.pizzaAPI()
        debugPrint(#fileID, #line, "!!! test case init")
    }
}

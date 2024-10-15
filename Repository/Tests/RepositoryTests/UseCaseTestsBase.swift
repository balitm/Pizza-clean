//
//  UseCaseTestsBase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
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
        _ = Container.shared.pizzaAPI.register {
            MockPizzaNetwork()
        }.singleton

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
                _ = Container.shared.storage.register {
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
        storage = Container.shared.storage()
        mock = Container.shared.pizzaAPI()
        debugPrint(#fileID, #line, "!!! test case init")
    }
}

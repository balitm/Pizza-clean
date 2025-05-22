//
//  Injection.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 11..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Factory
import RealmSwift

public final class DataSourceContainer: SharedContainer {
    public static let shared = DataSourceContainer()

    public init() {}

#if DEBUG
    private nonisolated(unsafe) var testRealm: Realm = {
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
            }
            debugPrint(#fileID, #line, "!!! test sequence init")

            return realm
        } catch {
            fatalError("test realm can't be inited:\n\(error)")
        }
    }()
#endif

    public let manager = ContainerManager()

    public var appConfig: Factory<AppConfigProtocol> {
        self { AppConfig() }
            .onTest { TestingAppConfig() }
            .singleton
    }

    public var pizzaAPI: Factory<PizzaNetwork> {
        // self { APIPizzaNetwork() }.singleton
        self { MockPizzaNetwork() }.singleton
    }

    public var storage: Factory<DataSource.Storage> {
        self {
            DataSource.Storage()
        }.singleton
    }
}

extension DataSourceContainer: AutoRegistering {
    public func autoRegister() {
#if DEBUG
        Self.shared.pizzaAPI.onPreview { MockPizzaNetwork() }
        Self.shared.pizzaAPI.onTest { MockPizzaNetwork() }

        Self.shared.storage.onTest { [unowned self] in
            debugPrint(#fileID, #line, "!!! test case init with", testRealm.configuration.fileURL?.absoluteString ?? "nil")
            return DS.Storage(realm: testRealm)
        }
#endif
    }
}

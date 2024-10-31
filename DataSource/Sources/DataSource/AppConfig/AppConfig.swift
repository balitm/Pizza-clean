//
//  AppConfig.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 16..
//

import Foundation

public protocol AppConfigProtocol {
    var flavour: AppFlavour { get }
    var appVersion: String { get }
    var appBuild: String { get }
    var pizzaBaseURL: String { get }
}

struct AppConfig: AppConfigProtocol {
    enum Key: String {
        case flavor = "APP_FLAVOR"
        case pizzaBaseURL = "PIZZA_API_URL"
    }

    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    public let flavour: AppFlavour = .init(rawValue: appFlavour) ?? .testing

    static let appFlavour: String = (try? value(for: .flavor)) ?? "testing"

    public let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"

    public let appBuild: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    public let pizzaBaseURL: String = (try? value(for: .pizzaBaseURL)) ?? "pizzaBaseURL"

    private static func value<T>(for key: Key) throws -> T where T: LosslessStringConvertible {
        let bundle = Bundle.main
        guard let object = bundle.object(forInfoDictionaryKey: key.rawValue) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

struct TestingAppConfig: AppConfigProtocol {
    public let flavour: AppFlavour = .testing
    public let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    public let appBuild: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    public let pizzaBaseURL = "http://localhost:4010"
}

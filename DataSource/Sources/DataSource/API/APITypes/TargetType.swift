//
//  TargetType.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 08..
//

import Foundation

struct EmptyBody: Codable {}

public enum Method: String, Equatable, Hashable, Sendable {
    /// `CONNECT` method.
    case connect = "CONNECT"
    /// `DELETE` method.
    case delete = "DELETE"
    /// `GET` method.
    case get = "GET"
    /// `HEAD` method.
    case head = "HEAD"
    /// `OPTIONS` method.
    case options = "OPTIONS"
    /// `PATCH` method.
    case patch = "PATCH"
    /// `POST` method.
    case post = "POST"
    /// `PUT` method.
    case put = "PUT"
    /// `QUERY` method.
    case query = "QUERY"
    /// `TRACE` method.
    case trace = "TRACE"
}

/// The protocol used to define the specifications necessary for a `MoyaProvider`.
protocol TargetType {
    /// The target's base `URL`.
    var baseURL: URL { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String? { get }

    /// The HTTP method used in the request.
    var method: Method { get }

    /// The reqest parameters.
    var requestParameters: RequestParameters { get }

    /// Provides stub data for use in testing. Default is `Data()`.
    var sampleData: Data { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }

    /// The timeout of the request.
    var timeout: TimeInterval { get }

    /// The timeout of the request.
    var retryCount: Int { get }
}

extension TargetType {
    var requestParameters: RequestParameters { .requestPlain }

    /// Provides stub data for use in testing. Default is `Data()`.
    var sampleData: Data { Data() }
}

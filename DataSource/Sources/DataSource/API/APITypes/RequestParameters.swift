//
//  RequestParameters.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 09..
//

import Foundation

enum ParameterEncoding {
    case queryString, JSON
}

/// Represents an HTTP task.
enum RequestParameters {
    /// A request with no additional data.
    case requestPlain

    /// A request body set with `Encodable` type
    case requestJSONEncodable(Encodable)

    /// A requests body set with encoded parameters.
    case requestParameters(parameters: [String: Any])

    /// A requests body set with encoded parameters combined with url parameters.
    case requestCompositeParameters(body: Encodable, urlParameters: [String: Any])
}

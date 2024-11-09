//
//  HTTPURLResponse+Extension.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 09..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain

private let kRequestIdHeader = "x-request-id"

extension HTTPURLResponse {
    var status: HTTPStatusCode {
        HTTPStatusCode(rawValue: statusCode) ?? .notFound
    }

    var requestId: String? {
        allHeaderFields[kRequestIdHeader] as? String
    }

    var isTimeout: Bool {
        status == .requestTimeout || status == .gatewayTimeout
    }
}

extension URLRequest {
    var requestId: String? {
        get {
            value(forHTTPHeaderField: kRequestIdHeader)
        }
        set {
            setValue(newValue, forHTTPHeaderField: kRequestIdHeader)
        }
    }
}

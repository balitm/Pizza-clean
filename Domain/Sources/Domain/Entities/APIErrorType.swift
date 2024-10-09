//
//  APIErrorType.swift
//  Domain
//
//  Created by Balázs Kilvády on 2024. 10. 07..
//

public struct APIError: Error {
    public enum Kind: Error {
        case invalidURL(String)
        case invalidRequest
        case disabled
        case invalidResponse
        case processingFailed
        case httpError(HTTPStatusCode)
        case connectionLost
        case netError(Error?)
        case offline
    }

    public let kind: Kind
    public let code: String?
    public let message: String?
    public private(set) var statusCode: HTTPStatusCode = .ok

    public init(statusCode: HTTPStatusCode? = nil, kind: Kind, code: String? = nil, message: String? = nil) {
        self.statusCode = statusCode ?? .ok
        self.code = code
        self.message = message

        // We can catch loadbalancer HTTP errors, and offer a retry?!?
        if statusCode == .requestTimeout || statusCode == .gatewayTimeout {
            self.kind = .httpError(.requestTimeout)
            return
        }

        if statusCode == .clientClosedRequest {
            self.kind = .httpError(.clientClosedRequest)
            return
        }

        self.kind = kind
    }

    public init(statusCode: HTTPStatusCode) {
        self.init(statusCode: statusCode, kind: .invalidResponse, code: nil, message: nil)
    }

    mutating func setStatusCode(_ code: HTTPStatusCode) {
        statusCode = code
    }

    public var description: String {
        "\(kind)"
    }
}

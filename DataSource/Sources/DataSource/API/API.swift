//
//  API.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/14/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Domain
import class UIKit.UIImage

typealias URLPath = (baseURL: URL, path: String?)

private struct ParamArray {
    let elements: [String]
}

public final class API: Sendable {
    /// Singleton instance
    static let shared = API()

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let session: URLSession

    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateHelper.dateTimeZoneFormatter)

        encoder = JSONEncoder()
        // encoder.outputFormatting = .sortedKeys
        encoder.dateEncodingStrategy = .formatted(DateHelper.dateTimeZoneFormatter)

        // An ephemeral session configuration object is similar to a default session configuration,
        // except that the corresponding session object doesn’t store caches, credential stores,
        // or any session-related data to disk. Instead, session-related data is stored in RAM.
        let config = URLSessionConfiguration.ephemeral

        session = URLSession(configuration: config)
    }

    func perform<T: Decodable>(type: T.Type = T.self, request: TargetType) async throws -> T {
        var body: Encodable?
        var parameters: [String: Any]?
        switch request.requestParameters {
        case let .requestParameters(params):
            parameters = params
        case let .requestJSONEncodable(encodable):
            body = encodable
        default:
            break
        }

        return try await performRequest(
            type: type,
            body: body,
            httpMethod: request.method.rawValue,
            httpHeaders: request.headers,
            parameters: parameters,
            timeout: request.timeout,
            path: URLPath(request.baseURL, request.path),
            retryNumber: request.retryCount
        )
    }

    @discardableResult
    func perform(request: TargetType) async throws -> Data {
        var body: Encodable?
        var parameters: [String: Any]?
        switch request.requestParameters {
        case let .requestParameters(params):
            parameters = params
        case let .requestJSONEncodable(encodable):
            body = encodable
        default:
            break
        }

        return try await performRequest(
            body: body,
            httpMethod: request.method.rawValue,
            httpHeaders: request.headers,
            parameters: parameters,
            timeout: request.timeout,
            path: URLPath(request.baseURL, request.path),
            retryNumber: request.retryCount
        )
    }

    private func performRequest<T>(
        type: T.Type = T.self,
        body: Encodable?,
        httpMethod: String,
        httpHeaders: [String: String]?,
        parameters: [String: Any]?,
        timeout: TimeInterval,
        path: URLPath,
        retryNumber: Int
    ) async throws -> T where T: Decodable {
        // Create request.
        var request = try createRequest(
            path,
            timeout: timeout,
            parameters: parameters,
            httpHeaders: httpHeaders
        )
        request.httpMethod = httpMethod

        // Set body type and value if we have body.
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let httpBody = try encoder.encode(body)
            request.httpBody = httpBody
        }

        NetworkLogger.log(request: request)

        // Execute the request with fetching the response data.
        let object = try await execute(type, APIError.self) {
            try await _perform(request, retryNumber)
        }
        return object
    }

    private func performRequest(
        body: Encodable?,
        httpMethod: String,
        httpHeaders: [String: String]?,
        parameters: [String: Any]?,
        timeout: TimeInterval,
        path: URLPath,
        retryNumber: Int
    ) async throws -> Data {
        // Create request, use non-default base url.
        var request = try createRequest(
            path,
            timeout: timeout,
            parameters: parameters,
            httpHeaders: httpHeaders
        )
        request.httpMethod = httpMethod

        // Set body type and value if we have body.
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let httpBody = try encoder.encode(body)
            request.httpBody = httpBody
        }

        NetworkLogger.log(request: request)

        // Execute the request with fetching the response data.
        let object = try await executeForData(APIError.self) {
            try await _perform(request, retryNumber)
        }
        return object.data
    }

    private func createRequest(
        _ path: URLPath,
        timeout: TimeInterval,
        parameters: [String: Any?]? = nil,
        httpHeaders: [String: String]? = nil
    ) throws -> URLRequest {
        let hostUrl: URL = try {
            let url: URL? = if let relativePath = path.path {
                URL(string: relativePath, relativeTo: path.baseURL)
            } else {
                path.baseURL
            }
            guard let url else {
                throw APIError(kind: .invalidURL("\(path.baseURL.absoluteString)/\(path.path ?? "")"))
            }
            return url
        }()

        var components = URLComponents()
        if let parameters, let params = mapValuesToQueryItems(parameters) {
            components.queryItems = params
        }

        guard let url = components.url(relativeTo: hostUrl) else {
            throw APIError(kind: .invalidURL("\(path.baseURL.absoluteString)/\(path.path ?? "")"))
        }

        var request = URLRequest(url: url, timeoutInterval: timeout)

        // Set additional http headers.
        if let httpHeaders, !httpHeaders.isEmpty {
            for (key, value) in httpHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }

    private func execute<T, E>(
        _ type: T.Type,
        _ errorType: E.Type,
        _ perform: () async throws -> (Data, HTTPURLResponse)
    ) async throws -> T where T: Decodable, E: APIErrorProtocol {
        do {
            // Fetch data.
            let (data, response) = try await perform()

            // Process result.
            if response.status.responseType == .success {
                return try processSucces(
                    type,
                    data,
                    requestId: response.requestId ?? ""
                )
            } else {
                // Handle general errors.
                let err = processError(
                    response.status,
                    data,
                    errorType,
                    requestId: response.requestId ?? ""
                )
                throw err
            }
        } catch let error as APIErrorProtocol {
            assert(error is E)
            DLog("Req specific error caught.")
            throw error
        } catch {
            DLog("caught: \(error)")
            throw APIError(kind: .invalidResponse)
        }
    }

    private func executeForData<E>(
        _ errorType: E.Type,
        _ perform: () async throws -> (Data, HTTPURLResponse)
    ) async throws -> (data: Data, statusCode: HTTPStatusCode) where E: APIErrorProtocol {
        do {
            // Fetch data.
            let (data, response) = try await perform()

            // Process result.
            if response.status.responseType == .success {
                return (data, response.status)
            } else {
                // Handle general errors.
                let err = processError(
                    response.status,
                    data,
                    errorType,
                    requestId: response.requestId ?? ""
                )
                throw err
            }
        } catch let error as APIErrorProtocol {
            assert(error is E)
            DLog("Req specific error caught.")
            throw error
        } catch {
            DLog("caught: \(error)")
            throw APIError(kind: .invalidResponse)
        }
    }

    private func _perform(_ request: URLRequest, _ retryNumber: Int) async throws -> (Data, HTTPURLResponse) {
        func getResult(retry: Bool = false) async throws -> (Data, HTTPURLResponse) {
            var data = Data()
            var response: URLResponse?
            do {
                var request = request
                if retry {
                    // Retry with a new requestID !!!
                    request.requestId = UUID().uuidString
                }
                (data, response) = try await session.data(for: request)
            } catch {
                DLog("caught: \(error)")
                let nserror = error as NSError
                if nserror.code == -1001 {
                    // timeout
                    response = HTTPURLResponse(
                        url: request.url!, statusCode: HTTPStatusCode.requestTimeout.rawValue,
                        httpVersion: nil, headerFields: nil
                    )!
                } else if nserror.code == -1009 {
                    // offline
                    throw APIError(kind: .offline)
                }
                throw APIError(kind: .netError(error))
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError(kind: .invalidResponse)
            }
            return (data, httpResponse)
        }

        var (data, httpResponse) = try await getResult()
        var i = 1

#if DEBUG
        // DLog("\n-----\nHeaders:\n")
        // for headerField in httpResponse.allHeaderFields {
        //     print(headerField.key, ":", headerField.value)
        // }
        if let JSONString = String(data: data, encoding: .utf8) {
            DLog("\n----\nReq: \(request.url?.absoluteString ?? "nil")\nResponse: \(httpResponse.statusCode)\n-----\n\(JSONString)")
        }
#endif

        while httpResponse.isTimeout && i < retryNumber {
            (data, httpResponse) = try await getResult(retry: true)
            i += 1
        }

        return (data, httpResponse)
    }

    private func processSucces<T>(
        _: T.Type,
        _ data: Data,
        requestId _: String
    ) throws -> T where T: Decodable {
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            DLog("Decoding failed: \(error)")
            throw error
        }
    }

    private func processError(
        _ status: HTTPStatusCode,
        _: Data,
        _: any APIErrorProtocol.Type,
        requestId _: String
    ) -> Error {
        DLog("status code: \(status.rawValue)")
        if status.responseType == .clientError {
            let error = APIError(statusCode: status)
            return error
        } else if status.responseType == .serverError {
            let error = APIError(statusCode: status, kind: .invalidResponse)
            return error
        }
        let error = APIError(statusCode: status, kind: .invalidResponse)
        return error
    }
}

private func mapValuesToQueryItems(_ source: [String: Any?]) -> [URLQueryItem]? {
    let destination = source
        .filter { $0.value != nil }
        .reduce(into: [URLQueryItem]()) { result, item in
            if let paramArray = item.value as? ParamArray {
                for val in paramArray.elements {
                    result.append(URLQueryItem(name: item.key + "[]", value: val))
                }
            } else if let collection = item.value as? [Any?] {
                let value = collection.filter { $0 != nil }.map { "\($0!)" }.joined(separator: ",")
                result.append(URLQueryItem(name: item.key, value: value))
            } else if let value = item.value {
                result.append(URLQueryItem(name: item.key, value: "\(value)"))
            }
        }

    if destination.isEmpty {
        return nil
    }
    return destination
}

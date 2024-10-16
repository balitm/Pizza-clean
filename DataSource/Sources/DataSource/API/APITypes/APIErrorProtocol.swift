//
//  APIErrorProtocol.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 09..
//

import Foundation
import Domain

protocol APIErrorProtocol: Error {
    func setStatusCode(_ code: HTTPStatusCode)
}

extension APIErrorProtocol {
    func setStatusCode(_: HTTPStatusCode) {}
}

extension APIError: APIErrorProtocol {}

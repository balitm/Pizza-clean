//
//  APIErrorType.swift
//  Domain
//
//  Created by Balázs Kilvády on 2024. 10. 07..
//

public enum APIErrorType: Error {
    case invalidURL
    case disabled
    case invalidJSON
    case processingFailed
    case status(code: Int)
    case connectionLost
    case netError(error: Error?)
}

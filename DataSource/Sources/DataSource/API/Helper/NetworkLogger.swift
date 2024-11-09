//
//  NetworkLogger.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 08..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import os

extension API {
    enum NetworkLogger {
        private static let _logger = Logger(subsystem: "Pizza", category: "NetworkLogger")

        static func log(request: URLRequest, data _: Data? = nil) {
            var lines = ["\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n"]

            let urlAsString = request.url?.absoluteString ?? ""
            let urlComponents = URLComponents(string: urlAsString)
            let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
            let path = "\(urlComponents?.path ?? "")"
            var query = "\(urlComponents?.query ?? "")"
            let host = "\(urlComponents?.host ?? "")"

            if !query.isEmpty {
                query.insert("?", at: query.startIndex)
            }
            var output = """
            \(urlAsString) \n\n
            \(method) \(path)\(query) HTTP/1.1 \n
            HOST: \(host)\n
            """
            for (key, value) in request.allHTTPHeaderFields ?? [:] {
                output += "\(key): \(value) \n"
            }
            if let body = request.httpBody {
                output += "\n \(String(data: body, encoding: .utf8) ?? "")"
                // } else if let body = data {
                //     let str = body.map { byte in
                //         if byte == 13 { return "" }
                //         let char = Character(.init(byte))
                //         if !char.isASCII { return "@" }
                //         return String(format: "%c", byte)
                //     }.joined()
                //     output += str
            }

            lines.append(output)
            lines.append("\n- - - - - - - - - - END - - - - - - - - - - \n")
            _logger.log("\(lines.joined(separator: "\n"))")
        }

        static func log(response: HTTPURLResponse?, data: Data?, error: Error?) {
            var lines = ["\n - - - - - - - - - - INCOMMING - - - - - - - - - - \n"]

            let urlString = response?.url?.absoluteString
            let components = NSURLComponents(string: urlString ?? "")
            let path = "\(components?.path ?? "")"
            let query = "\(components?.query ?? "")"
            var output = ""
            if let urlString {
                output += "\(urlString)"
                output += "\n\n"
            }
            if let statusCode = response?.statusCode {
                output += "HTTP \(statusCode) \(path)?\(query)\n"
            }
            if let host = components?.host {
                output += "Host: \(host)\n"
            }
            for (key, value) in response?.allHeaderFields ?? [:] {
                output += "\(key): \(value)\n"
            }
            if let body = data {
                output += "\n\(String(data: body, encoding: .utf8) ?? "")\n"
            }
            if error != nil {
                output += "\nError: \(error!.localizedDescription)\n"
            }

            lines.append(output)
            lines.append("\n - - - - - - - - - -  END - - - - - - - - - - \n")

            _logger.log("\(lines.joined(separator: "\n"))")
        }
    }
}

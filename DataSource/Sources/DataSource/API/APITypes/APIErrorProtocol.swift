//
//  APIErrorProtocol.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 09..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain

protocol APIErrorProtocol: Error {}

extension APIError: APIErrorProtocol {}

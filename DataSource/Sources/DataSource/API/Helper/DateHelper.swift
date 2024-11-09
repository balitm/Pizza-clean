//
//  DateHelper.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 08..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public enum DateHelper {
    public static let kDateFormat = "yyyy-MM-dd"
    public static let kDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss"
    public static let kDateTimeZoneFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    public static let kDayInterval: TimeInterval = 60 * 60 * 24

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = kDateFormat
        return formatter
    }()

    public static let hunDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Budapest")!
        formatter.dateFormat = kDateFormat
        return formatter
    }()

    public static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = kDateTimeFormat
        return formatter
    }()

    public static let dateTimeZoneFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = kDateTimeZoneFormat
        return formatter
    }()
}

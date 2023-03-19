// Created by Alex Yaro on 2023-03-19.

import Foundation

public extension Calendar {

    /// Gregorian calendar with UTC time zone for testing
    static var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .init(secondsFromGMT: 0)!
        return calendar
    }
}

// Created by Alex Yaro on 2023-08-22.

import Foundation

public extension Date {
    enum Month: Int {
        case january = 1
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
    }

    static func testDate(
        _ month: Month,
        _ day: Int,
        _ year: Int,
        calendar: Calendar = .testCalendar
    ) -> Self! {
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month.rawValue
        dateComponents.year = year
        return calendar.date(from: dateComponents)
    }
}

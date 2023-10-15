// Created by Alex Yaro on 2023-10-01.

import Foundation

extension TimeInterval {

    static func minutes(_ count: Double) -> TimeInterval {
        count * 60
    }

    static func hours(_ count: Double) -> TimeInterval {
        count * 60 * 60
    }
}

extension TimeInterval {

    func formatted(
        units: NSCalendar.Unit,
        unitsStyle: DateComponentsFormatter.UnitsStyle = .abbreviated
    ) -> String {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = unitsStyle
        durationFormatter.allowedUnits = units

        guard let str = durationFormatter.string(from: self) else {
            assertionFailure("Couldn't format TimeInterval of \(self)")
            return "\(self / 60)m"
        }

        return str
    }
}

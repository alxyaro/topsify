// Created by Alex Yaro on 2023-11-07.

import Foundation

extension Int {

    // Note: this shadows the iOS 15 formatting function
    @available(iOS, deprecated: 15, message: "Switch to native formatted() API")
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }

    func formattedWithAbbreviation(
        maximumFractionDigits: Int = 1
    ) -> String {
        let abbreviation = NumberAbbreviation(for: self, maximumFractionDigits: maximumFractionDigits)

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = maximumFractionDigits

        let abbreviatedValue = Double(self) / Double(abbreviation?.rawValue ?? 1)
        let formattedNumber = numberFormatter.string(from: NSNumber(value: abbreviatedValue)) ?? ""
        return formattedNumber + (abbreviation?.formattedUnit ?? "")
    }
}

private enum NumberAbbreviation: Int, CaseIterable {
    case millions = 1_000_000
    case thousands = 1_000

    var formattedUnit: String {
        switch self {
        case .millions:
            NSLocalizedString("M", comment: "Abbreviation for millions, e.g. 15.2M")
        case .thousands:
            NSLocalizedString("K", comment: "Abbreviation for thousands, e.g. 2.5K")
        }
    }

    init?(for value: Int, maximumFractionDigits: Int) {
        for abbreviation in Self.allCases {
            let dividedValue = Double(value) / Double(abbreviation.rawValue / 1000)
            let roundFactor = pow(10, Double(maximumFractionDigits))
            let roundedDividedValue = round(dividedValue * roundFactor) / roundFactor

            if roundedDividedValue >= 1000 {
                self = abbreviation
                return
            }
        }
        return nil
    }
}

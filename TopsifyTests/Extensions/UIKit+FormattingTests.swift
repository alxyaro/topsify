// Created by Alex Yaro on 2023-11-21.

@testable import Topsify
import XCTest

final class UIKitPlusFormattingTests: XCTestCase {

    func test_formattedWithAbbreviation_forNonAbbreviatedNumbers() {
        XCTAssertEqual((-1_000_000).test(), "-1,000,000") // negatives are currently no-op
        XCTAssertEqual(1.test(), "1")
        XCTAssertEqual(125.test(), "125")
        XCTAssertEqual(999.test(), "999")
    }

    // MARK: - One Decimal

    func test_formattedWithAbbreviation_forNumbersInTheThousands() {
        XCTAssertEqual(1_000.test(), "1K")
        XCTAssertEqual(1_200.test(), "1.2K")
        XCTAssertEqual(1_249.test(), "1.2K")
        XCTAssertEqual(1_250.test(), "1.2K") // half-even rounding (at exactly half, rounds to even number)
        XCTAssertEqual(1_251.test(), "1.3K")
        XCTAssertEqual(999_949.test(), "999.9K")
    }

    func test_formattedWithAbbreviation_forNumbersInTheMillions() {
        XCTAssertEqual(999_950.test(), "1M")
        XCTAssertEqual(1_000_000.test(), "1M")
        XCTAssertEqual(1_300_000.test(), "1.3M")
        XCTAssertEqual(1_349_999.test(), "1.3M")
        XCTAssertEqual(1_350_000.test(), "1.4M")
        XCTAssertEqual(1_000_000_000.test(), "1,000M")
    }

    // MARK: - Two Decimals

    func test_formattedWithAbbreviation_forNumbersInTheThousands_with2Decimals() {
        XCTAssertEqual(1_000.test(decimals: 2), "1K")
        XCTAssertEqual(1_200.test(decimals: 2), "1.2K")
        XCTAssertEqual(1_250.test(decimals: 2), "1.25K")
        XCTAssertEqual(1_256.test(decimals: 2), "1.26K")
        XCTAssertEqual(999_994.test(decimals: 2), "999.99K")
    }

    func test_formattedWithAbbreviation_forNumbersInTheMillions_with2Decimals() {
        XCTAssertEqual(999_995.test(decimals: 2), "1M")
        XCTAssertEqual(1_000_000.test(decimals: 2), "1M")
        XCTAssertEqual(1_300_000.test(decimals: 2), "1.3M")
        XCTAssertEqual(1_350_000.test(decimals: 2), "1.35M")
        XCTAssertEqual(1_359_000.test(decimals: 2), "1.36M")
        XCTAssertEqual(1_000_000_000.test(decimals: 2), "1,000M")
    }
}

private extension Int {

    func test(decimals: Int = 1) -> String {
        self.formattedWithAbbreviation(maximumFractionDigits: decimals)
    }
}

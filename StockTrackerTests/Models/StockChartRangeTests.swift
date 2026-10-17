//
//  StockChartRangeTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 10/17/26.
//

import Foundation
@testable import StockTracker
import Testing

struct StockChartRangeTests {
    @Test(arguments: [(StockChartRange.week, "2026-03-24"), (.month, "2026-02-28"), (.year, "2025-03-31")])
    func `calendar boundaries use exchange dates`(range: StockChartRange, cutoff: String) throws {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        formatter.dateFormat = "yyyy-MM-dd"
        let start = try #require(formatter.date(from: cutoff))
        let end = try #require(formatter.date(from: "2026-03-31"))
        let points = [start.addingTimeInterval(-1), start, end].map {
            StockPricePoint(date: $0, price: 100, timeZone: formatter.timeZone)
        }
        #expect(range.filter(points.reversed()) == Array(points.suffix(2)))
        #expect(range.filter([]).isEmpty)
    }
}

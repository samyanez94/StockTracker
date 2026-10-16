//
//  StockPriceChartDataTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct StockPriceChartDataTests {
    private let points = [
        StockPricePoint(date: Date(timeIntervalSince1970: 0), price: 90),
        StockPricePoint(date: Date(timeIntervalSince1970: 300), price: 110),
    ]

    @Test
    func `readout and delta follow selection or latest point`() {
        let latest = StockPriceChartData(points: points, currency: "USD", previousClose: 100, selectedDate: nil)
        let selected = StockPriceChartData(points: points, currency: "USD", previousClose: 100, selectedDate: points[0].date)
        #expect(latest.displayedPoint == points[1])
        #expect(latest.percentChange == 10)
        #expect(selected.displayedPoint == points[0])
        #expect(selected.percentChange == -10)
    }

    @Test(arguments: [50.0, 150.0])
    func `price scale includes previous close and all prices`(baseline: Double) {
        let data = StockPriceChartData(points: points, currency: "USD", previousClose: baseline, selectedDate: nil)
        #expect(data.priceDomain.lowerBound < min(baseline, 90))
        #expect(data.priceDomain.upperBound > max(baseline, 110))
    }

    @Test
    func `single point has nonzero scale ranges`() {
        let data = StockPriceChartData(points: [points[0]], currency: "USD", previousClose: nil, selectedDate: nil)
        #expect(data.priceDomain.lowerBound < 90)
        #expect(data.priceDomain.upperBound > 90)
        #expect(data.dateDomain.lowerBound < points[0].date)
        #expect(data.dateDomain.upperBound > points[0].date)
        #expect(data.percentChange == nil)
    }

    @Test
    func `empty chart and invalid baseline remain supported`() {
        let data = StockPriceChartData(points: [], currency: "USD", previousClose: .nan, selectedDate: nil)
        #expect(data.displayedPoint == nil)
        #expect(data.previousCloseBaseline == nil)
        #expect(data.priceDomain.lowerBound.isFinite)
        #expect(data.priceDomain.upperBound.isFinite)
        #expect(data.formattedDelta == "—")
    }
}

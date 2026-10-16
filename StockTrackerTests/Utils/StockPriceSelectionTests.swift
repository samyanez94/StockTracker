//
//  StockPriceSelectionTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation
@testable import StockTracker
import Testing

struct StockPriceSelectionTests {
    @Test(arguments: [(-100.0, 0.0), (0, 0), (149, 0), (150, 0), (151, 300), (300, 300), (900, 300)])
    func `snaps to nearest bar and clamps at boundaries`(selection: Double, expected: Double) {
        let points = [300.0, 0.0].map {
            StockPricePoint(date: Date(timeIntervalSince1970: $0), price: 100 + $0)
        }
        let result = StockPriceSelection.nearest(to: Date(timeIntervalSince1970: selection), in: points)
        #expect(result?.date == Date(timeIntervalSince1970: expected))
    }

    @Test
    func `empty and single point histories are supported`() {
        let date = Date(timeIntervalSince1970: 0)
        #expect(StockPriceSelection.nearest(to: date, in: []) == nil)
        let point = StockPricePoint(date: date, price: 100)
        #expect(StockPriceSelection.nearest(to: date.addingTimeInterval(900), in: [point]) == point)
    }

    @Test(arguments: [(110.0, 100.0, 10.0), (90, 100, -10), (100, 100, 0), (204.18, 202.92, 0.6209343583678297)])
    func `delta compares displayed price with previous close`(price: Double, previousClose: Double, expected: Double) throws {
        let point = StockPricePoint(date: Date(timeIntervalSince1970: 0), price: price)
        let delta = try #require(point.percentChange(from: previousClose))
        #expect(abs(delta - expected) < 0.000001)
    }

    @Test
    func `delta requires valid previous close`() {
        let point = StockPricePoint(date: Date(timeIntervalSince1970: 0), price: 100)
        for baseline: Double? in [nil, 0, -1, .infinity, .nan] {
            #expect(point.percentChange(from: baseline) == nil)
        }
    }
}

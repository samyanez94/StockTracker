//
//  TwelveDataTimeSeriesResponse.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation

/// Decodes the metadata and closing prices needed by a line chart.
struct TwelveDataTimeSeriesResponse: Decodable {
    let meta: Metadata
    let values: [Bar]

    struct Metadata: Decodable {
        let symbol: String
        let interval: String
        let exchangeTimezone: String

        enum CodingKeys: String, CodingKey {
            case symbol, interval
            case exchangeTimezone = "exchange_timezone"
        }
    }

    struct Bar: Decodable {
        let datetime: String
        let close: String
    }

    func points(for symbol: String, range: StockChartRange = .day) throws -> [StockPricePoint] {
        guard meta.symbol == symbol,
              meta.interval == range.interval,
              let timeZone = TimeZone(identifier: meta.exchangeTimezone)
        else {
            throw StockServiceError.invalidResponse
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = range.isIntraday ? "yyyy-MM-dd HH:mm:ss" : "yyyy-MM-dd"
        formatter.isLenient = false
        var dates = Set<Date>()
        return try values.map { bar in
            guard let date = formatter.date(from: bar.datetime),
                  formatter.string(from: date) == bar.datetime,
                  let price = Double(bar.close), price.isFinite, price > 0,
                  dates.insert(date).inserted
            else {
                throw StockServiceError.invalidResponse
            }
            return StockPricePoint(date: date, price: price, timeZone: timeZone)
        }
        .sorted { $0.date < $1.date }
    }
}

//
//  Quote+Formatting.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

extension Quote {
    var formattedPrice: String {
        formatPrice(price)
    }

    var formattedPercentChange: String {
        let sign = percentChange >= 0 ? "+" : ""
        return sign + percentChange.formatted(.number.precision(.fractionLength(2))) + "%"
    }

    var formattedPriceWithCurrency: String {
        "\(formatPrice(price)) \(currency)"
    }

    var formattedChange: String {
        guard let change else {
            return "—"
        }
        return (change >= 0 ? "+" : "") + formatPrice(change)
    }

    var formattedOpen: String {
        formatPrice(open)
    }

    var formattedPreviousClose: String {
        formatPrice(previousClose)
    }

    var formattedVolume: String {
        formatVolume(volume)
    }

    var formattedAverageVolume: String {
        formatVolume(averageVolume)
    }

    var formattedHigh: String {
        formatPrice(high)
    }

    var formattedLow: String {
        formatPrice(low)
    }

    var formattedFiftyTwoWeekHigh: String {
        formatPrice(fiftyTwoWeekHigh)
    }

    var formattedFiftyTwoWeekLow: String {
        formatPrice(fiftyTwoWeekLow)
    }

    private func formatVolume(_ value: Int64?) -> String {
        value?.formatted(.number.notation(.compactName).precision(.fractionLength(0 ... 2))) ?? "—"
    }

    private func formatPrice(_ value: Double?) -> String {
        value?.formatted(.currency(code: currency).precision(.fractionLength(2))) ?? "—"
    }
}

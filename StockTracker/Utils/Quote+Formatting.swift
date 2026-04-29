//
//  Quote+Formatting.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

extension Quote {
    var formattedPrice: String {
        price.formatted(.currency(code: "USD"))
    }

    var formattedPercentChange: String {
        let sign = percentChange >= 0 ? "+" : ""
        return sign + percentChange.formatted(.number.precision(.fractionLength(2))) + "%"
    }
}

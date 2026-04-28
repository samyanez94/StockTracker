//
//  Quote.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

struct Quote: Sendable {
    let symbol: String
    let price: Double
    let percentChange: Double
}

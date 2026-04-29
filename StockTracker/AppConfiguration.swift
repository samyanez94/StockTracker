//
//  AppConfiguration.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

struct AppConfiguration {
    let usesMockData: Bool
    let stockDataAPIKey: String

    static let current = AppConfiguration(
        usesMockData: true,
        stockDataAPIKey: Secrets.stockDataAPIKey,
    )
}

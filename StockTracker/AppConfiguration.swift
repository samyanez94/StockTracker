//
//  AppConfiguration.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

struct AppConfiguration {
    let usesMockData: Bool
    let twelveDataAPIKey: String

    static let current = AppConfiguration(
        usesMockData: true,
        twelveDataAPIKey: Secrets.twelveDataAPIKey,
    )
}

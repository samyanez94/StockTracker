//
//  Stock.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

nonisolated struct Stock: Codable, Identifiable, Hashable {
    var id: String {
        symbol
    }

    let symbol: String
    let companyName: String
}

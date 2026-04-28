//
//  Stock.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

struct Stock: Identifiable, Hashable, Sendable {
    let id = UUID()
    let symbol: String
    let companyName: String
}

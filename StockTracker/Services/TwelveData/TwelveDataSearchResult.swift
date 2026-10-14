//
//  TwelveDataSearchResult.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

nonisolated struct TwelveDataSearchResult: Decodable {
    let symbol: String
    let instrumentName: String
    let country: String
    let currency: String
    let instrumentType: String

    enum CodingKeys: String, CodingKey {
        case symbol
        case country
        case currency
        case instrumentName = "instrument_name"
        case instrumentType = "instrument_type"
    }
}

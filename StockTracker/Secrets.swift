//
//  Secrets.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

enum Secrets {
    static var twelveDataAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "TwelveDataAPIKey") as? String ?? ""
    }
}

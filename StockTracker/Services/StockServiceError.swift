//
//  StockServiceError.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

enum StockServiceError: Error {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int)
}

extension StockServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "We couldn't create the request."
        case .invalidResponse:
            "We couldn't read the server response."
        case .badStatusCode:
            "We couldn't load the latest prices."
        }
    }
}

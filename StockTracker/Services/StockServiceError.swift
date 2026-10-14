//
//  StockServiceError.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

nonisolated enum StockServiceError: Error, Equatable {
    case missingMockData
    case apiError(code: Int, message: String)
    case invalidURL
    case invalidResponse
    case missingAPIKey
    case badStatusCode(Int)
}

extension StockServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingMockData:
            "No mock data is available for this request."
        case let .apiError(code, message):
            code == 429 ? "The data request limit has been reached. Please try again later." : message
        case .badStatusCode(429):
            "The data request limit has been reached. Please try again later."
        case .invalidURL:
            "We couldn't create the request."
        case .invalidResponse:
            "We couldn't read the server response."
        case .missingAPIKey:
            "We couldn't find the API key."
        case .badStatusCode:
            "We couldn't load the latest prices."
        }
    }
}

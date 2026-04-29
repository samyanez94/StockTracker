//
//  StockServiceErrorTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/27/26.
//

@testable import StockTracker
import Testing

struct StockServiceErrorTests {
    @Test
    func `error description returns user friendly message`() {
        #expect(StockServiceError.invalidURL.errorDescription == "We couldn't create the request.")
        #expect(StockServiceError.invalidResponse.errorDescription == "We couldn't read the server response.")
        #expect(StockServiceError.missingAPIKey.errorDescription == "We couldn't find the API key.")
        #expect(StockServiceError.badStatusCode(500).errorDescription == "We couldn't load the latest prices.")
    }
}

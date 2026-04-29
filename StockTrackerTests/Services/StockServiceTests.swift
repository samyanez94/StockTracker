//
//  StockServiceTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/28/26.
//

@testable import StockTracker
import Testing

struct StockServiceTests {
    @Test
    func `mock mode does not require API key`() async throws {
        let service = StockService(usesMockData: true, apiKey: "")

        let quotes = try await service.fetch(
            StockDataQuotesRequest(symbols: ["AAPL"]),
        )

        #expect(quotes.count == 1)
        #expect(quotes.first?.symbol == "AAPL")
    }

    @Test
    func `network mode requires API key`() async {
        let service = StockService(usesMockData: false, apiKey: "")

        do {
            _ = try await service.fetch(
                StockDataQuotesRequest(symbols: ["AAPL"]),
            )
            Issue.record("Expected fetch to throw.")
        } catch StockServiceError.missingAPIKey {
        } catch {
            Issue.record("Expected missing API key error, got \(error).")
        }
    }
}

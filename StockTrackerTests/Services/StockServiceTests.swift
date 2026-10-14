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
    @MainActor
    func `mock mode does not require API key`() async throws {
        let service = StockService(usesMockData: true, apiKey: "")

        let quotes = try await service.fetchQuotes(symbols: ["AAPL"])

        #expect(quotes.count == 1)
        #expect(quotes.first?.symbol == "AAPL")
    }

    @Test
    @MainActor
    func `network mode requires API key`() async {
        let service = StockService(usesMockData: false, apiKey: "")

        do {
            _ = try await service.fetchQuotes(symbols: ["AAPL"])
            Issue.record("Expected fetch to throw.")
        } catch StockServiceError.missingAPIKey {
        } catch {
            Issue.record("Expected missing API key error, got \(error).")
        }
    }

    @Test
    @MainActor
    func `empty quote list needs neither API key nor network`() async throws {
        let service: any StockServicing = StockService(usesMockData: false, apiKey: "")
        let quotes = try await service.fetchQuotes(symbols: [])
        #expect(quotes.isEmpty)
    }

    @Test
    @MainActor
    func `search requires API key in network mode`() async {
        let service: any StockServicing = StockService(usesMockData: false, apiKey: "")
        await #expect(throws: StockServiceError.missingAPIKey) {
            try await service.searchStocks(query: "Apple")
        }
    }
}

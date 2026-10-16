//
//  TwelveDataSearchRequestTests.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct TwelveDataSearchRequestTests {
    @Test
    func `search URL encodes query`() throws {
        let url = try TwelveDataSearchRequest(query: "Apple & Co").url(apiKey: "test-key")
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "api.twelvedata.com")
        #expect(components.path == "/symbol_search")
        #expect(components.queryItems?.contains(URLQueryItem(name: "symbol", value: "Apple & Co")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "apikey", value: "test-key")) == true)
    }

    @Test(arguments: ["", "  "])
    func `search requests reject missing keys`(key: String) {
        #expect(throws: StockServiceError.missingAPIKey) {
            try TwelveDataSearchRequest(query: "Apple").url(apiKey: key)
        }
    }

    @Test
    func `API errors surface for search`() {
        let data = Data(#"{"status":"error","code":429,"message":"Too many requests"}"#.utf8)
        let error = StockServiceError.apiError(code: 429, message: "Too many requests")
        #expect(throws: error) { try TwelveDataSearchRequest(query: "Apple").decode(data) }
        #expect(error.errorDescription == StockServiceError.badStatusCode(429).errorDescription)
    }

    @Test
    func `search filters foreign stocks and deduplicates symbols`() throws {
        let data = Data(#"{"data":[{"symbol":"AAPL","instrument_name":"Apple Inc.","country":"United States","currency":"USD","instrument_type":"Common Stock"},{"symbol":"AAPL","instrument_name":"Apple duplicate","country":"United States","currency":"USD","instrument_type":"Common Stock"},{"symbol":"AAPL","instrument_name":"Apple foreign listing","country":"Germany","currency":"EUR","instrument_type":"Common Stock"},{"symbol":"SPY","instrument_name":"ETF","country":"United States","currency":"USD","instrument_type":"ETF"}],"status":"ok"}"#.utf8)
        let stocks = try TwelveDataSearchRequest(query: "Apple").decode(data)
        #expect(stocks == [Stock(symbol: "AAPL", companyName: "Apple Inc.")])
        #expect(try TwelveDataSearchRequest(query: "none").decode(Data(#"{"data":[],"status":"ok"}"#.utf8)).isEmpty)
    }

    @Test
    func `mock catalog supports company name search`() async throws {
        let service: any StockServicing = StockService(usesMockData: true, apiKey: "")
        let results = try await service.searchStocks(query: "  microSOFT  ")
        #expect(results.map(\.symbol) == ["MSFT"])
        let empty = try await service.searchStocks(query: "no match")
        #expect(empty.isEmpty)
    }
}

//
//  TwelveDataRequestTests.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct TwelveDataRequestTests {
    @Test
    func `quote URL uses Twelve Data parameters`() throws {
        let url = try TwelveDataQuoteRequest(symbols: ["AAPL", "MSFT"]).url(apiKey: "test-key")
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "api.twelvedata.com")
        #expect(components.path == "/quote")
        #expect(components.queryItems?.contains(URLQueryItem(name: "symbol", value: "AAPL,MSFT")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "apikey", value: "test-key")) == true)
    }

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
    func `requests reject missing keys`(key: String) {
        #expect(throws: StockServiceError.missingAPIKey) {
            try TwelveDataQuoteRequest(symbols: ["AAPL"]).url(apiKey: key)
        }
        #expect(throws: StockServiceError.missingAPIKey) {
            try TwelveDataSearchRequest(query: "Apple").url(apiKey: key)
        }
    }

    @Test
    func `single quote maps string values`() throws {
        let data = Data(#"{"symbol":"AAPL","close":"204.18","percent_change":"0.62"}"#.utf8)
        let quote = try #require(TwelveDataQuoteRequest(symbols: ["AAPL"]).decode(data).first)
        #expect(quote.symbol == "AAPL")
        #expect(quote.price == 204.18)
        #expect(quote.percentChange == 0.62)
    }

    @Test
    func `batch quotes preserve requested order`() throws {
        let data = Data(#"{"MSFT":{"symbol":"MSFT","close":"391.44","percent_change":"-0.34"},"AAPL":{"symbol":"AAPL","close":"204.18","percent_change":"0.62"}}"#.utf8)
        let quotes = try TwelveDataQuoteRequest(symbols: ["AAPL", "MSFT"]).decode(data)
        #expect(quotes.map(\.symbol) == ["AAPL", "MSFT"])
        #expect(quotes.last?.percentChange == -0.34)
    }

    @Test(arguments: ["not-a-price", "NaN", "Infinity"])
    func `malformed quote values fail`(value: String) {
        let data = Data("{\"symbol\":\"AAPL\",\"close\":\"\(value)\",\"percent_change\":\"0.62\"}".utf8)
        #expect(throws: StockServiceError.invalidResponse) {
            try TwelveDataQuoteRequest(symbols: ["AAPL"]).decode(data)
        }
    }

    @Test
    func `API errors surface for quotes and search`() {
        let data = Data(#"{"status":"error","code":429,"message":"Too many requests"}"#.utf8)
        let error = StockServiceError.apiError(code: 429, message: "Too many requests")
        #expect(throws: error) { try TwelveDataQuoteRequest(symbols: ["AAPL"]).decode(data) }
        #expect(throws: error) { try TwelveDataQuoteRequest(symbols: ["AAPL", "MSFT"]).decode(data) }
        #expect(throws: error) { try TwelveDataSearchRequest(query: "Apple").decode(data) }
        #expect(error.errorDescription == StockServiceError.badStatusCode(429).errorDescription)
    }

    @Test
    func `partial batch errors fail refresh`() {
        let data = Data(#"{"AAPL":{"symbol":"AAPL","close":"204.18","percent_change":"0.62"},"BAD":{"status":"error","code":404,"message":"Unknown symbol"}}"#.utf8)
        #expect(throws: StockServiceError.apiError(code: 404, message: "Unknown symbol")) {
            try TwelveDataQuoteRequest(symbols: ["AAPL", "BAD"]).decode(data)
        }
    }

    @Test
    func `missing batch entry fails`() {
        let data = Data(#"{"AAPL":{"symbol":"AAPL","close":"204.18","percent_change":"0.62"}}"#.utf8)
        #expect(throws: StockServiceError.invalidResponse) {
            try TwelveDataQuoteRequest(symbols: ["AAPL", "MSFT"]).decode(data)
        }
    }

    @Test
    func `search filters foreign stocks and deduplicates symbols`() throws {
        let data = Data(#"{"data":[{"symbol":"AAPL","instrument_name":"Apple Inc.","country":"United States","currency":"USD","instrument_type":"Common Stock"},{"symbol":"AAPL","instrument_name":"Apple duplicate","country":"United States","currency":"USD","instrument_type":"Common Stock"},{"symbol":"AAPL","instrument_name":"Apple foreign listing","country":"Germany","currency":"EUR","instrument_type":"Common Stock"},{"symbol":"SPY","instrument_name":"ETF","country":"United States","currency":"USD","instrument_type":"ETF"}],"status":"ok"}"#.utf8)
        let stocks = try TwelveDataSearchRequest(query: "Apple").decode(data)
        #expect(stocks == [Stock(symbol: "AAPL", companyName: "Apple Inc.")])
        #expect(try TwelveDataSearchRequest(query: "none").decode(Data(#"{"data":[],"status":"ok"}"#.utf8)).isEmpty)
    }

    @Test
    func `mock catalog supports quote and company name search`() async throws {
        let service: any StockServicing = StockService(usesMockData: true, apiKey: "")
        let quotes = try await service.fetchQuotes(symbols: TwelveDataMockData.stocks.map(\.symbol))
        #expect(quotes.count == 7)
        #expect(quotes.first?.price == 204.18)
        #expect(quotes.contains { $0.percentChange < 0 })
        let results = try await service.searchStocks(query: "  microSOFT  ")
        #expect(results.map(\.symbol) == ["MSFT"])
        let empty = try await service.searchStocks(query: "no match")
        #expect(empty.isEmpty)
    }

    @Test
    func `mock mode rejects unsupported symbols without networking`() async {
        await #expect(throws: StockServiceError.missingMockData) {
            try await StockService(usesMockData: true, apiKey: "").fetchQuotes(symbols: ["UNKNOWN"])
        }
    }

}

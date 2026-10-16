//
//  TwelveDataQuoteRequestTests.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct TwelveDataQuoteRequestTests {
    @Test
    func `quote URL uses Twelve Data parameters`() throws {
        let url = try TwelveDataQuoteRequest(symbols: ["AAPL", "MSFT"]).url(apiKey: "test-key")
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "api.twelvedata.com")
        #expect(components.path == "/quote")
        #expect(components.queryItems?.contains(URLQueryItem(name: "symbol", value: "AAPL,MSFT")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "apikey", value: "test-key")) == true)
    }

    @Test(arguments: ["", "  "])
    func `quote requests reject missing keys`(key: String) {
        #expect(throws: StockServiceError.missingAPIKey) {
            try TwelveDataQuoteRequest(symbols: ["AAPL"]).url(apiKey: key)
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
    func `API errors surface for quotes`() {
        let data = Data(#"{"status":"error","code":429,"message":"Too many requests"}"#.utf8)
        let error = StockServiceError.apiError(code: 429, message: "Too many requests")
        #expect(throws: error) { try TwelveDataQuoteRequest(symbols: ["AAPL"]).decode(data) }
        #expect(throws: error) { try TwelveDataQuoteRequest(symbols: ["AAPL", "MSFT"]).decode(data) }
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
    func `mock catalog supports quotes`() async throws {
        let service: any StockServicing = StockService(usesMockData: true, apiKey: "")
        let quotes = try await service.fetchQuotes(symbols: TwelveDataMockData.stocks.map(\.symbol))
        #expect(quotes.count == 7)
        #expect(quotes.first?.price == 204.18)
        #expect(quotes.contains { $0.percentChange < 0 })
    }

    @Test
    func `mock mode rejects unsupported symbols without networking`() async {
        await #expect(throws: StockServiceError.missingMockData) {
            try await StockService(usesMockData: true, apiKey: "").fetchQuotes(symbols: ["UNKNOWN"])
        }
    }

    @Test
    func `quote details map into domain model`() throws {
        let data = Data(#"{"symbol":"AAPL","close":"204.18","percent_change":"0.62","currency":"USD","change":"1.26","open":"203.33","previous_close":"202.92","volume":"45000000","average_volume":"52000000","low":"201.30","high":"206.22","fifty_two_week":{"low":"147.01","high":"253.18"}}"#.utf8)
        let quote = try #require(TwelveDataQuoteRequest(symbols: ["AAPL"]).decode(data).first)
        #expect(quote.currency == "USD")
        #expect(quote.change == 1.26)
        #expect(quote.open == 203.33)
        #expect(quote.previousClose == 202.92)
        #expect(quote.volume == 45_000_000)
        #expect(quote.averageVolume == 52_000_000)
        #expect(quote.low == 201.30)
        #expect(quote.high == 206.22)
        #expect(quote.fiftyTwoWeekLow == 147.01)
        #expect(quote.fiftyTwoWeekHigh == 253.18)
    }

    @Test
    func `unavailable statistics preserve core quote`() throws {
        let data = Data(#"{"symbol":"AAPL","close":"204.18","percent_change":"0.62","open":null,"previous_close":"N/A","volume":"-1","average_volume":"unknown","low":"NaN","high":"Infinity","fifty_two_week":{"low":null}}"#.utf8)
        let quote = try #require(TwelveDataQuoteRequest(symbols: ["AAPL"]).decode(data).first)
        #expect(quote.price == 204.18)
        #expect(quote.open == nil)
        #expect(quote.previousClose == nil)
        #expect(quote.volume == nil)
        #expect(quote.averageVolume == nil)
        #expect(quote.low == nil)
        #expect(quote.high == nil)
        #expect(quote.formattedChange == "—")
        #expect(quote.formattedOpen == "—")
        #expect(quote.formattedDayRange == "—")
        #expect(quote.formattedFiftyTwoWeekRange == "—")
    }

    @Test
    func `mock quotes include consistent statistics`() async throws {
        let service = StockService(usesMockData: true, apiKey: "")
        let quotes = try await service.fetchQuotes(symbols: TwelveDataMockData.stocks.map(\.symbol))
        for quote in quotes {
            let previous = try #require(quote.previousClose)
            let change = try #require(quote.change)
            let open = try #require(quote.open)
            let low = try #require(quote.low)
            let high = try #require(quote.high)
            let yearLow = try #require(quote.fiftyTwoWeekLow)
            let yearHigh = try #require(quote.fiftyTwoWeekHigh)
            #expect(abs(quote.price - previous - change) < 0.000001)
            #expect(abs(change / previous * 100 - quote.percentChange) < 0.01)
            #expect(low <= min(open, quote.price))
            #expect(high >= max(open, quote.price))
            #expect(yearLow <= low && yearHigh >= high)
            #expect(quote.volume != nil && quote.averageVolume != nil)
        }
    }
}

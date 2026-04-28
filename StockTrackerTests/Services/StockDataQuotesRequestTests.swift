//
//  StockDataQuotesRequestTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/27/26.
//

@testable import StockTracker
import Foundation
import Testing

struct StockDataQuotesRequestTests {
    
    @Test
    func urlIncludesEndpointAndQueryItems() throws {
        let request = StockDataQuotesRequest(symbols: ["AAPL", "MSFT"])
        let url = try request.url
        let components = try #require(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )
        #expect(components.scheme == "https")
        #expect(components.host == "api.stockdata.org")
        #expect(components.path == "/v1/data/quote")
        #expect(components.queryValue(named: "symbols") == "AAPL,MSFT")
        #expect(components.queryValue(named: "api_token") == Secrets.stockDataAPIKey)
    }

    @Test
    func decodeReturnsQuotes() throws {
        let json = """
        {
            "data": [
                {
                    "ticker": "AAPL",
                    "price": 204.18,
                    "day_change": 0.62
                }
            ]
        }
        """
        let request = StockDataQuotesRequest(symbols: ["AAPL"])
        let quotes = try request.decode(Data(json.utf8))
        #expect(quotes.count == 1)
        #expect(quotes.first?.symbol == "AAPL")
        #expect(quotes.first?.price == 204.18)
        #expect(quotes.first?.percentChange == 0.62)
    }
}

private extension URLComponents {
    func queryValue(named name: String) -> String? {
        queryItems?.first { $0.name == name }?.value
    }
}

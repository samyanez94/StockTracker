//
//  StockDataSearchRequestTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation
@testable import StockTracker
import Testing

struct StockDataSearchRequestTests {
    @Test
    func `url includes endpoint and query items`() throws {
        let request = StockDataSearchRequest(query: "tsla")
        let url = try request.url
        let components = try #require(
            URLComponents(url: url, resolvingAgainstBaseURL: false),
        )
        #expect(components.scheme == "https")
        #expect(components.host == "api.stockdata.org")
        #expect(components.path == "/v1/entity/search")
        #expect(components.queryValue(named: "search") == "tsla")
        #expect(components.queryValue(named: "api_token") == Secrets.stockDataAPIKey)
    }

    @Test
    func `decode returns stocks`() throws {
        let json = """
        {
            "data": [
                {
                    "symbol": "TSLA",
                    "name": "Tesla Inc",
                    "type": "equity",
                    "industry": null,
                    "exchange": null,
                    "exchange_long": null,
                    "mic_code": null,
                    "country": "us"
                }
            ]
        }
        """
        let request = StockDataSearchRequest(query: "tsla")
        let stocks = try request.decode(Data(json.utf8))
        #expect(stocks.count == 1)
        #expect(stocks.first?.symbol == "TSLA")
        #expect(stocks.first?.companyName == "Tesla Inc")
    }
}

private extension URLComponents {
    func queryValue(named name: String) -> String? {
        queryItems?.first { $0.name == name }?.value
    }
}

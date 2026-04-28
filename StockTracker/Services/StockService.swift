//
//  StockService.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

protocol StockServicing {
    func fetch<Request: StockRequest>(_ request: Request) async throws -> Request.Response
}

struct StockService: StockServicing {
    private let usesMockData: Bool

    nonisolated init(usesMockData: Bool = false) {
        self.usesMockData = usesMockData
    }

    nonisolated func fetch<Request: StockRequest>(_ request: Request) async throws -> Request.Response {
        if usesMockData, let mockResponse = await request.mockResponse() {
            return mockResponse
        }
        let (data, response) = try await URLSession.shared.data(from: request.url)
        try validate(response)

        return try await request.decode(data)
    }

    private nonisolated func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StockServiceError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw StockServiceError.badStatusCode(httpResponse.statusCode)
        }
    }
}

//
//  TwelveDataResult.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

/// Twelve Data can return an error envelope even when the HTTP request succeeds.
nonisolated enum TwelveDataResult<Value: Decodable>: Decodable {
    case success(Value)
    case failure(code: Int, message: String)

    private enum CodingKeys: String, CodingKey {
        case status, code, message
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decodeIfPresent(String.self, forKey: .status) == "error" {
            self = try .failure(
                code: container.decode(Int.self, forKey: .code),
                message: container.decode(String.self, forKey: .message)
            )
        } else {
            self = try .success(Value(from: decoder))
        }
    }

    func value() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(code, message):
            throw StockServiceError.apiError(code: code, message: message)
        }
    }
}

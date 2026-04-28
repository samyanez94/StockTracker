import Foundation

enum Secrets {
    static var stockDataAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "StockDataAPIKey") as? String ?? ""
    }
}

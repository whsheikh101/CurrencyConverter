//
//  Transformers.swift
//  CurrenyConverter
//
//  Created by Waqas Haider on 18/01/2021.
//

import Foundation
import ObjectMapper

open class ExchangeRateArrayTransform: TransformType {
    public func transformToJSON(_ value: [ExchangeRate]?) -> [[String : Any]]? {
        guard let exchangeRates = value else { return nil }
        return exchangeRates.map { $0.toJSON() }
    }
    
    public func transformFromJSON(_ value: Any?) -> [ExchangeRate]? {
        guard let exchangeRatesJSON = value as? [String: Any] else { return nil }
        var exchangeRates = [ExchangeRate]()
        for dictionary in exchangeRatesJSON {
            // country code
            let countryCode = dictionary.key.replacingOccurrences(of: "USD", with: "")
            
            // escape empty country code's record
            guard !countryCode.isEmpty else { continue }
            let json = ["code": countryCode,
                        "rate": dictionary.value]
            guard let exchangeRate = ExchangeRate(JSON: json) else { continue }
            exchangeRates.append(exchangeRate)
        }
        return exchangeRates
    }
    
    public typealias Object = [ExchangeRate]
    public typealias JSON = [[String: Any]]
}

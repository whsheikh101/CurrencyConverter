//
//  ExchangeRateDetails.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 18/01/2021.
//

import Foundation
import ObjectMapper
import Alamofire
import SwiftyBeaver
import PromiseKit

class ExchangeRateDetails: Object {
    var source = ""
    var timestamp: Date?
    var exchangeRates = [ExchangeRate]()
    
    override func mapping(map: Map) {
        source         <- map["source"]
        timestamp      <- (map["timestamp"], DateTransform())
        exchangeRates  <- (map["quotes"], ExchangeRateArrayTransform())
    }
}

extension ExchangeRateDetails {
    enum Router: Requestable {
        case live
        
        var path: PathPattern? {
            return .live
        }
        var parameters: Parameters? {
            return ["access_key": Configuration.current.environment.accessKey ?? "",
                    "format": "1"]
        }
    }
}

extension ExchangeRateDetails {
    static func getLiveExchangeRates() -> Promise<ExchangeRateDetails> {
        return Promise { resolver in
            Router.live.request { (response: DataResponse<ExchangeRateDetails>) in
                
                // response
                Log.debug(response)
                
                // check error
                guard response.error == nil else {
                    resolver.reject(response.error!)
                    return
                }
                guard let exchangeRateDetails = response.value else {
                    let error = AppError(1001, domain: "Error", message: AppError.Errors.inValidResponse.message)
                    resolver.reject(error)
                    return
                }
                
                // fulfill
                resolver.fulfill(exchangeRateDetails)
            }
        }
    }
}

public class ExchangeRate: Object {
    var currencyCode = ""
    var currencyRate = 0.0
    
    public override func mapping(map: Map) {
        currencyCode <- map["code"]
        currencyRate <- map["rate"]
    }
}

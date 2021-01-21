//
//  Configuration.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 17/01/2021.
//

import Foundation
import ObjectMapper

class Configuration {
    static let current = Configuration()
    
    private init() {
        // load all configurations one time
        all = Bundle.main.infoDictionary?["Configuration"] as? JSONDictionary ?? [:]
    }
    // all configuration keys from info Plist
    var all = JSONDictionary()
    
    // environment
    var environment: Environment {
        guard let environment = Environment(JSON: all["Environment"] as? JSONDictionary ?? [:]) else {
            fatalError("😂😜 ADD Environment TO YOUR CONFIGURATION FILE!!!")
        }
        return environment
    }
    
    // current scheme. by default it's development
    var scheme: Scheme {
        return Configuration.current.environment.scheme ?? .Development
    }
    
    // base URL
    var baseURL: URL? {
        guard let `protocol` = Configuration.current.environment.protocol, let host = Configuration.current.environment.host else {
            fatalError("😂😜 ADD HOST AND PROTOCOL TO YOUR CONFIGURATION FILE!!!")
        }
        return URL(string: `protocol` + "://" + host )
    }
}

extension Configuration {
    enum Scheme: String {
        case Development
    }
}

extension Configuration {
    class Environment: Object {
        // URL's protocol (http/https)
        var `protocol`: String?
        
        // host address
        var host: String?
        
        // current scheme
        var scheme: Scheme?
        
        // access key
        var accessKey: String?
        
        override func mapping(map: Map) {
            `protocol` <- map["protocol"]
            host       <- map["host"]
            scheme     <- (map["scheme"], EnumTransform<Scheme>())
            accessKey  <- map["accessKey"]
        }
    }
}

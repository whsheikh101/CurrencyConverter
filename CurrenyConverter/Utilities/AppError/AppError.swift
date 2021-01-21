//
//  AppError.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 16/01/2021.
//

import Foundation

class AppError: NSError {
    
    var message = ""
    
    init (_ code: Int, domain: String, message: String) {
        super.init(domain: domain, code: code, userInfo: nil)
        self.message = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppError {
    enum Errors: String, Error {
        case inValidResponse = "Invalid response, Please try again."
        case invalidRequest = "Request cannot be completed at this moment."
        case unKnown = "Something went wrong!"
        
        var message: String {
            return rawValue
        }
    }
}

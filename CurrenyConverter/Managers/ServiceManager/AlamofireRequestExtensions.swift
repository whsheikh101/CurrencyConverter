//
//  AlamofireRequestExtensions.swift
//  USA Wholesale
//
//  Created by Waqas Haider on 14/01/2020.
//  Copyright © 2020 Q-Solutions. All rights reserved.
//

import Alamofire
import SwiftyBeaver
import ObjectMapper
import SVProgressHUD

public extension Alamofire.Request {
    
    /// Prints the log for the request
    @discardableResult
    func debug() -> Self {
        Log.info(debugDescription)
        return self
    }
}

public extension Alamofire.DataRequest {
    
    @discardableResult
    func validateErrors() -> Self {
        return validate { [weak self] (request, response, data) -> Alamofire.Request.ValidationResult in
            
            // get status code from server
            let code = response.statusCode
            
            // check the request url
            let requestURL = String(describing: request?.url?.absoluteString ?? "NO URL")
            
            var result: Alamofire.Request.ValidationResult = .success
            
            guard let data = data else {
                // create error
                let error = AppError(code, domain: "Error", message: AppError.Errors.inValidResponse.message)
                result =  .failure(error)
                return result
            }
                       
            // check if response is empty
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
                
                self?.log(code: code, url: requestURL, message: "Empty response" as AnyObject, isError: false, request: request)
                if code == 200 {
                    return result
                } else {
                    let error = AppError(-999, domain: "empty", message: AppError.Errors.inValidResponse.message)
                    result = .failure(error)
                    return result
                }
            }
            
            // check response contains error
            if let errorMessage = json["error"] as? String, !errorMessage.isEmpty {
                
                // create error
                let error = AppError(code, domain: "Error", message: errorMessage)
                self?.log(code: code, url: requestURL, message: json as AnyObject, isError: true, request: request)
                result = .failure(error)
                
            } else {
                self?.log(code: code, url: requestURL, message: json as AnyObject, isError: false, request: request)
                result = .success
            }
            return result
        }
            
            // validate for request errors
            .validate()
            
            // log request
            .debug()
    }
    
    private func log(code: Int, url: String, message: AnyObject, isError: Bool, request: URLRequest?) {
        
        if isError {
            Log.error("FAILED")
        }
        
        Log.info("Status Code >> \(code)")
        Log.info("URL >> \(url)")
        Log.info("Request >> \(request?.allHTTPHeaderFields ?? [:])")
        Log.info("Response >> \(message)")
    }
}


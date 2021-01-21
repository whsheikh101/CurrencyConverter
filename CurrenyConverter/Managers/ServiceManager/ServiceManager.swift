//
//  ServiceManager.swift
//  USA Wholesale
//
//  Created by Waqas Haider on 14/01/2020.
//  Copyright © 2020 Q-Solutions. All rights reserved.
//

import Foundation
import Alamofire

class ServiceManager {
    static let shared = ServiceManager()
    
    var manager: Alamofire.SessionManager
    
    private init() {
        
        // configure manager with default
        manager = Alamofire.SessionManager(configuration: .default)
        
        // adapter
        manager.adapter = ServiceAdapter()
    }
    
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return manager.request(urlRequest)
    }
    
    func upload(_ multipartFormData: @escaping (MultipartFormData) -> Void, urlRequest: URLRequestConvertible, encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?) {
        manager.upload(multipartFormData: multipartFormData, with: urlRequest, encodingCompletion: encodingCompletion)
    }
    
    func download(_ urlRequest: URLRequestConvertible, to destination: DownloadRequest.DownloadFileDestination? = nil) -> DownloadRequest {
        return manager.download(urlRequest, to: destination)
    }
}

extension ServiceManager {
    class ServiceAdapter: RequestAdapter {
        
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = "USAWholesale"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                    return "iOS \(versionString)"
                }()
                return "\(executable)/\(appVersion) (iPhone; iOS \(osNameVersion); Scale/3.00)"
            }
            return "Alamofire"
        }()
        
        func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            var urlRequest = urlRequest
            
            // update default http headers
            urlRequest.allHTTPHeaderFields?.merge(Alamofire.SessionManager.defaultHTTPHeaders) { (current, _) in current }
            
            // set user agent
            urlRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            // customize
            return urlRequest
        }
    }
}

extension ServiceManager {
    struct API {
        static var baseUrl: URL? {
            return Configuration.current.baseURL
        }
    }
}

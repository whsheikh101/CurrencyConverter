//
//  Requestable.swift
//  USA Wholesale
//
//  Created by Waqas Haider on 14/01/2020.
//  Copyright © 2020 Q-Solutions. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper

protocol Requestable: URLRequestConvertible {
    
    var method: HTTPMethod { get }
    var path: PathPattern? { get }
    var parameters: Parameters? { get }
    var downloadFileDestination: DownloadRequest.DownloadFileDestination? { get }
    var timeoutIntervalForRequest: TimeInterval { get }
    var encoding: EncodingType { get }
    var moduleSpecificURL: URL? { get }
    var additionalHeader: [String: String]? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    
    @discardableResult
    func request(with responseObject: @escaping (DefaultDataResponse) -> Void) -> DataRequest
    
    @discardableResult
    func request<T: BaseMappable>(with responseObject: @escaping (DataResponse<T>) -> Void) -> DataRequest
    
    @discardableResult
    func request<T: BaseMappable>(with responseArray: @escaping (DataResponse<[T]>) -> Void) -> DataRequest
    
    @discardableResult
    func download(from url: URL, with responseObject: @escaping (DefaultDownloadResponse) -> Void) -> DownloadRequest
    
    @discardableResult
    func request<T: BaseMappable>(with keyPath: String?, responseArray: @escaping (DataResponse<[T]>) -> Void) -> DataRequest
}

extension Requestable {
    
    // default HTTP Method is get
    var method: HTTPMethod {
        return .get
    }
    
    // just to add nil as default path
    var path: PathPattern? {
        return nil
    }
       
    // just to add nil as default parameter
    var parameters: Parameters? {
        return nil
    }
    
    // no default download file destination
    var downloadFileDestination: DownloadRequest.DownloadFileDestination? {
        return nil
    }
    
    // default timeoutIntervalForRequest
    var timeoutIntervalForRequest: TimeInterval {
        return 60.0
    }
    
    // default request encoding
    var encoding: EncodingType {
        return .urlEncoded
    }
    
    var moduleSpecificURL: URL? {
        return nil
    }
    
    var additionalHeader: [String: String]? {
        return nil
    }
    
    // default caching policy for URL request
    var cachePolicy: URLRequest.CachePolicy {
        return URLRequest.CachePolicy.useProtocolCachePolicy
    }
    
    var url: URL {
        guard var url = ServiceManager.API.baseUrl else {
            fatalError("😂😜 ADD Environment TO YOUR CONFIGURATION FILE!!!")
        }
        
        if let path = path, !path.name.isEmpty {
            url = url.appendingPathComponent(path.name)
        }       
        return url
    }
    
    func asURLRequest() throws -> URLRequest {
        
        // update timeoutIntervalForRequest from router
        ServiceManager.shared.manager.session.configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        
        // check for module specific url
        var urlRequest = try URLRequest(url: moduleSpecificURL ?? url, method: method)
        urlRequest.cachePolicy = cachePolicy
        
        // add additional headers if any
        additionalHeader?.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        // encoding
        switch encoding {
        case .jsonEncoded:
            return try Alamofire.JSONEncoding.default.encode(urlRequest, with: parameters)
        case .urlEncoded:
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        case .queryStringEncoded:
            return try Alamofire.URLEncoding.queryString.encode(urlRequest, with: parameters)
        case .none:
            return urlRequest
        }
    }
    
    @discardableResult
    func request(with responseObject: @escaping (DefaultDataResponse) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).response(completionHandler: responseObject).validateErrors()
    }
    
    @discardableResult
    func request<T: BaseMappable>(with responseObject: @escaping (DataResponse<T>) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).responseObject(completionHandler: responseObject).validateErrors()
    }
    
    @discardableResult
    func request<T: BaseMappable>(with responseArray: @escaping (DataResponse<[T]>) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).responseArray(completionHandler: responseArray).validateErrors()
    }
    
    @discardableResult
    func request<T: BaseMappable>(with keyPath: String?, mapToObject object: T?, with responseObject: @escaping (DataResponse<T>) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).responseObject(keyPath:keyPath, mapToObject: object, completionHandler: responseObject).validateErrors()
    }
    
    @discardableResult
    func download(from url: URL, with responseObject: @escaping (DefaultDownloadResponse) -> Void) -> DownloadRequest {
        return ServiceManager.shared.manager.download(url, to: downloadFileDestination).response(completionHandler: responseObject)
    }
    
    @discardableResult
    func request<T: BaseMappable>(with keyPath: String?, responseArray: @escaping (DataResponse<[T]>) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).responseArray(keyPath: keyPath, completionHandler: responseArray).validateErrors()
    }
    
    @discardableResult
    func request<T: BaseMappable>(with keyPath: String?, responseObject: @escaping (DataResponse<T>) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).responseObject(keyPath: keyPath, completionHandler: responseObject).validateErrors()
    }
}

protocol Uploadable: Requestable {
    func upload(with responseObject: @escaping (SessionManager.MultipartFormDataEncodingResult) -> Void)
}

extension Uploadable {
    
    func upload(with responseObject: @escaping (SessionManager.MultipartFormDataEncodingResult) -> Void) {
        
        ServiceManager.shared.upload({ multipartFormData in
            
            guard let parameters = self.parameters else { return }
            
            for (key, value) in parameters {
                if let image = value as? UIImage, let imageData = image.jpegData(compressionQuality: 0.6) {
                    multipartFormData.append(imageData, withName: key, fileName: key+".jpg", mimeType: "image/jpeg")
                } else if let url = value as? URL {
                    self.handleUrl(url: url, key: key, multipartFormData: multipartFormData)
                } else if let intValue = value as? Int, let formData = "\(intValue)".data(using: String.Encoding.utf8) {
                    multipartFormData.append(formData, withName: key)
                } else if let intValue = value as? Double, let formData = "\(intValue)".data(using: String.Encoding.utf8) {
                    multipartFormData.append(formData, withName: key)
                } else if let data = (value as AnyObject).data?(using: String.Encoding.utf8.rawValue) {
                    multipartFormData.append(data, withName: key)
                } else {
                    // no actions
                }
            }
        }, urlRequest: self, encodingCompletion: responseObject)
    }
    
    private func handleUrl(url: URL,key: String, multipartFormData: MultipartFormData) {
        
        if url.pathExtension == "jpeg" {
            if let image = UIImage(contentsOfFile: url.path), let imageData = image.jpegData(compressionQuality: 0.001) {
                multipartFormData.append(imageData, withName: key, fileName: key+".jpg", mimeType: "image/jpeg")
            }
        } else if url.pathExtension.lowercased() == "mp4" {
            if let data = try? Data(contentsOf: url) {
                multipartFormData.append(data, withName: key, fileName: key+".mp4", mimeType: "video/mp4")
            }
        } else if url.pathExtension.lowercased() == "mov" {
            if let data = try? Data(contentsOf: url) {
                multipartFormData.append(data, withName: key, fileName: key+".mov", mimeType: "video/mov")
            }
        } else if url.pathExtension == "gpx" || url.pathExtension == "kml" {
            if let data = try? Data(contentsOf: url) {
                multipartFormData.append(data, withName: key, fileName: url.lastPathComponent, mimeType: "application/gpx+xml")
            }
        } else {
            if let data = try? Data(contentsOf: url) {
                multipartFormData.append(data, withName: key, fileName: key+".json", mimeType: "application/json")
            }
        }
    }
}

public enum EncodingType: String {
    
    case jsonEncoded
    case urlEncoded
    case queryStringEncoded
    case none
}

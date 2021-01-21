//
//  Object.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 17/01/2021.
//

import Foundation
import ObjectMapper
public class Object: Mappable {
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {}
}

//
//  DateExtensions.swift
//  CurrenyConverter
//
//  Created by Waqas Haider on 18/01/2021.
//

import Foundation

extension Date {
    func string(with formate: String? = "MM/dd/yy hh:mm:ss a") -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formate
        return dateformatter.string(from: self)
    }
}

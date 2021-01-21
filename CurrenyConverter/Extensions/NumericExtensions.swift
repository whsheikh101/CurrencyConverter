//
//  NumericExtensions.swift
//  CurrenyConverter
//
//  Created by Waqas Haider on 21/01/2021.
//

import Foundation

extension Formatter {
    static let thousandSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}

extension Numeric {
    var withThousandSeparator: String { Formatter.thousandSeparator.string(for: self) ?? "" }
}

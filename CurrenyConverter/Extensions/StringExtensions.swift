//
//  StringExtensions.swift
//  CurrenyConverter
//
//  Created by Waqas Haider on 18/01/2021.
//

import Foundation

extension String {
    func trimWhiteSpaces() -> Self {
        return trimmingCharacters(in: .whitespaces)
    }
    
    func contains(_ text: String) -> Bool {
        return range(of: text, options: .caseInsensitive) != nil
    }
    
    // returns ranges of substrings
    func ranges(of text: String) -> [NSRange]? {
        return try? NSRegularExpression(pattern: text, options: .caseInsensitive)
            .matches(in: self, options: .withTransparentBounds, range: NSRange(location: 0, length: count))
            .map { $0.range }
    }
}

extension String {
    func date(with format: String? = "MM/dd/yy hh:mm:ss a") -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.date(from: self)
    }
}

extension String {
    public func removeThousandSeparator() -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.number(from: self)?.intValue ?? 0
    }
}

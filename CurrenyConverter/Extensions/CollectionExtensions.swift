//
//  CollectionExtensions.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 20/01/2021.
//

import Foundation

extension Collection {
    subscript(optional index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

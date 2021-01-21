//
//  Identifiable.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 20/01/2021.
//

import Foundation
import UIKit

protocol Identifiable {
    static var identifier: String { get }
}

extension UIResponder: Identifiable {
    static var identifier: String {
        return "\(self)"
    }
}

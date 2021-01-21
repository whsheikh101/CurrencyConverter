//
//  Utils.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 17/01/2021.
//

import Foundation
import UIKit
import SwiftyBeaver

public typealias JSONDictionary = [String: Any]
typealias Log = SwiftyBeaver

func topController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    
    if let navigationController = base as? UINavigationController {
        return topController(base: navigationController.visibleViewController)
        
    } else if let tabBarController = base as? UITabBarController, let selected = tabBarController.selectedViewController {
        return topController(base: selected)
        
    } else if let presented = base?.presentedViewController {
        return topController(base: presented)
    }
    return base
}


//
//  UITableViewExtensions.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 20/01/2021.
//

import Foundation
import UIKit

extension UITableView {
    func showNoDataView(with message: String) {
        separatorStyle = .none
        let labelNoData = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 100))
        labelNoData.text = message
        labelNoData.textAlignment = .center
        backgroundView = labelNoData
        reloadData()
    }
    
    func hideNoDataView() {
        separatorStyle = .singleLine
        backgroundView = nil
        reloadData()
    }
}

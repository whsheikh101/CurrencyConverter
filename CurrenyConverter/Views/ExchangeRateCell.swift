//
//  ExchangeRateCell.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 19/01/2021.
//

import UIKit

class ExchangeRateCell: UITableViewCell {
    
    var desiredAmount: Int?
    var exchangeRate: ExchangeRate? {
        didSet {
            configureView()
        }
    }
    
    @IBOutlet weak var labelExchangeRate: UILabel?
    
    private func configureView() {
        guard let exchangeRate = exchangeRate else { return }
        guard let desiredAmount = desiredAmount else { return }
        let calculatedAmount = Double(desiredAmount) * exchangeRate.currencyRate
        labelExchangeRate?.text = desiredAmount.withThousandSeparator + " USD = " + calculatedAmount.rounded(toPlaces: 2).withThousandSeparator + " \(exchangeRate.currencyCode)"
    }
}

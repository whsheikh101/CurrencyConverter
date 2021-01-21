//
//  ExchangeRatesViewController.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 16/01/2021.
//

import UIKit
import SVProgressHUD

class ExchangeRatesViewController: UIViewController {
    
    var desiredAmount: Int?
    var exchangeRates = [ExchangeRate]()
    var lastUpdatedDate: Date?
    var displayExchangeRates = [ExchangeRate]() {
        didSet {
            configureView()
        }
    }
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var searchBar: UISearchBar?
    
    private func configureView() {
        guard !exchangeRates.isEmpty else {
            tableView?.showNoDataView(with: "No exchange available.")
            return
        }
        tableView?.hideNoDataView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get exchange rates live data
        SVProgressHUD.show(withStatus: "Loading...")
        ExchangeRateDetails.getLiveExchangeRates().done { [weak self] exchangeRateDetails in
            // update models
            self?.lastUpdatedDate = exchangeRateDetails.timestamp
            self?.exchangeRates = exchangeRateDetails.exchangeRates
            self?.displayExchangeRates = exchangeRateDetails.exchangeRates
        }.catch { error in
            // show error message
            guard let appError = error as? AppError else { return }
            SVProgressHUD.showError(withStatus: appError.message)
        }.finally {
            // dismiss
            SVProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DesiredAmountViewControllerSegue" {
            guard let desiredAmountViewController = segue.destination as? DesiredAmountViewController else { return }
            desiredAmountViewController.delegate = self
            desiredAmountViewController.desiredAmount = desiredAmount
        }
    }
    
    @IBAction func buttonActionDesiredAmount(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "DesiredAmountViewControllerSegue", sender: nil)
    }
}

extension ExchangeRatesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayExchangeRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let exchangeRateCell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateCell.identifier) as? ExchangeRateCell else { return ExchangeRateCell() }
        guard let exchangeRate = displayExchangeRates[optional: indexPath.row] else { return ExchangeRateCell() }
        exchangeRateCell.desiredAmount = desiredAmount ?? 1
        exchangeRateCell.exchangeRate = exchangeRate
        return exchangeRateCell
    }
}

extension ExchangeRatesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filter(with: searchBar.text?.trimWhiteSpaces() ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter(with: searchBar.text?.trimWhiteSpaces() ?? "")
    }
    
    func filter(with text: String) {
        guard !exchangeRates.isEmpty else { return }
        guard !text.isEmpty else {
            displayExchangeRates = exchangeRates
            return
        }
        
        displayExchangeRates = exchangeRates.filter { (exchangeRate: ExchangeRate) -> Bool in
            return (exchangeRate.currencyCode.contains(text))
        }
    }
}

extension ExchangeRatesViewController: DesiredAmountViewControllerDelegate {
    func desiredAmountViewController(_ desiredAmountViewController: DesiredAmountViewController, didCompletedWith desiredAmount: Int) {
        
        // update desired amount
        self.desiredAmount = desiredAmount
        
        // configure view
        configureView()
    }
}


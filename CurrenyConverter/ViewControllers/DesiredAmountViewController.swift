//
//  DesiredAmountViewController.swift
//  CurrenyConverter
//
//  Created by Waqas Haider Sheikh on 20/01/2021.
//

import UIKit
import SVProgressHUD

protocol DesiredAmountViewControllerDelegate {
    func desiredAmountViewController(_ desiredAmountViewController: DesiredAmountViewController, didCompletedWith desiredAmount: Int)
}

class DesiredAmountViewController: UIViewController {
    
    var desiredAmount: Int?
    var delegate: DesiredAmountViewControllerDelegate?
    
    @IBOutlet weak var labelDisplayAmount: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure view
        configureView()
    }
    
    private func configureView() {
        guard let desiredAmount = desiredAmount else { return }
        labelDisplayAmount?.text = desiredAmount.withThousandSeparator
    }
    
    @IBAction func buttonActionNumber(_ sender: UIButton) {
        let newValue = sender.tag.description
        guard let displayAmount = labelDisplayAmount?.text?.removeThousandSeparator() else { return }
        guard displayAmount > 0 else {
            labelDisplayAmount?.text = newValue
            return
        }
        var displayAmountInString = displayAmount.description
        displayAmountInString.append(newValue)
        guard let desiredAmount = Int(displayAmountInString) else { return }
        labelDisplayAmount?.text = desiredAmount.withThousandSeparator
    }
    
    @IBAction func buttonActionClear(_ sender: UIButton) {
        labelDisplayAmount?.text = "0"
    }
    
    @IBAction func buttonActionDone(_ sender: UIButton) {
        guard let desiredAmount = labelDisplayAmount?.text?.removeThousandSeparator(), desiredAmount > 0 else {
            SVProgressHUD.showError(withStatus: "Amount should be greater than or equals to 1.")
            return
        }
        
        // delegate with desired amount
        delegate?.desiredAmountViewController(self, didCompletedWith: desiredAmount)
        
        // pop to previous screen
        navigationController?.popViewController(animated: true)
    }
}

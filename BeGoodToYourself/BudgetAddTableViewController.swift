//
//  BudgetAddTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class BudgetAddTableViewController: UITableViewController, UITextFieldDelegate {
    
    //-View Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    //-Global objects, properties & variables
    var events: Events!
    var dataString:String?
    var priceString:String?
    
    //set the textfield delegates
    let priceTextDelegate = PriceTextDelegate()
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Textfield delegate values
        self.priceTextField.delegate = priceTextDelegate
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            textField.becomeFirstResponder()
        }
        else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            priceTextField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //-Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveDataAdd" {
            dataString = textField.text
            priceString = priceTextField.text
        }
        print("Segue Error")
    }
    
}

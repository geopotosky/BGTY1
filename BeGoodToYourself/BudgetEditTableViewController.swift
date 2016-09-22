//
//  BudgetEditTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit
import CoreData

class BudgetEditTableViewController: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    //-View outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    //-Global objects, properties & variables
    var events: Events!
    var budgetIndexPath: IndexPath!
    var dataString:String?
    var priceString:String?
    
    //-Set the textfield delegates
    let priceTextDelegate = PriceTextDelegate()
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Textfield delegate values
        self.priceTextField.delegate = priceTextDelegate
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        
        let budget = fetchedResultsController.object(at: budgetIndexPath) 
        textField.text = budget.itemBudgetText
        priceTextField.text = budget.priceBudgetText

    }
    
    
    //-Add the "sharedContext" convenience property
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    //-Fetch Budget data
    lazy var fetchedResultsController: NSFetchedResultsController<Budget> = {
        
        let fetchRequest = NSFetchRequest<Budget>(entityName: "Budget")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "itemBudgetText", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "events == %@", self.events);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
        managedObjectContext: self.sharedContext,
        sectionNameKeyPath: nil,
        cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    //-Table view data source
    
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
        if segue.identifier == "saveDataEdit" {
            dataString = textField.text
            priceString = priceTextField.text
        }
        print("Segue Error")

    }
    
    
}


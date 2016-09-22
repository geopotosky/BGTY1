//
//  TodoEditTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//


import UIKit
import CoreData

class TodoEditTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    //-View Outlets
    @IBOutlet weak var editModelTextField: UITextField!
    
    //-Global objects, properties & variables
    var events: Events!
    var todosIndexPath: IndexPath!
    var editedModel:String?
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            //-Call Fetch method
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        
        let todos = fetchedResultsController.object(at: todosIndexPath) 
        editModelTextField.text = todos.todoListText
        
    }
    
    
    //-Add the "sharedContext" convenience property
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    //-Fetch To Do List data
    lazy var fetchedResultsController: NSFetchedResultsController<TodoList> = {
        
        let fetchRequest = NSFetchRequest<TodoList>(entityName: "TodoList")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "todoListText", ascending: true)]
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
            editModelTextField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    //-Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveDataEdit" {
            editedModel = editModelTextField.text
        }
        print("Segue Error")

    }
    
    
}




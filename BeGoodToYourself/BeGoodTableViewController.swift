//
//  BeGoodTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit
import CoreData
import EventKit


class BeGoodTableViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    //-View Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventImageView: UIImageView!
    
    //-Global objects, properties & variables
    var events = [Events]()
    var eventIndex: Int!
    var eventIndexPath: IndexPath!
    
    //-Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Create Navbar Buttons
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(BeGoodTableViewController.addEvent))
        
        //-Manage Top and Bottom bar colors
        //-Green Bars
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        self.navigationController!.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        
        //-Add notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(BeGoodTableViewController.refreshList), name: NSNotification.Name(rawValue: "TodoListShouldRefresh"), object: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        //-Unarchive the event when the list is first shown
        self.events = NSKeyedUnarchiver.unarchiveObject(withFile: eventsFilePath) as? [Events] ?? [Events]()
        
        //-Call the Welcome Alert
        welcomeAlertMessage()
        
    }
    
    //-Only allow 64 events (push notification limitation)
    func refreshList() {
        //todoItems = TodoList.sharedInstance.allItems()
        if (events.count >= 64) {
            self.navigationItem.rightBarButtonItem!.isEnabled = false // disable 'add' button
        }
        tableView.reloadData()
    }
    
    
    //-Perform when view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        //-Archive the graph any time this list of events is displayed.
        NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
        
        //-Brute Force Reload the scene to view table updates
        self.tableView.reloadData()
        
    }
    
    
    //-Reset the Table Edit view when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        resetEditing(false, animated: false)
    }
    
    
    //-Set Table Editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //-Reset the Table Edit view when the view disappears
    func resetEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }

    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController<Events> = {
        
        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textEvent", ascending: true)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    //-Configure Cell
    func configureCell(_ cell: UITableViewCell, withEvent event: Events) {
        
        //-Format the Date for the cell
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        //dateFormatter.timeZone = TimeZone()
        
        //-Set the cell values for the event
        let eventImage2 = event.eventImage
        let finalImage = UIImage(data: eventImage2! as Data)
        cell.textLabel!.text = event.textEvent
        
        if (event.isOverdue) { // the current time is later than the to-do item's deadline
            cell.detailTextLabel?.textColor = UIColor.red
        } else {
            cell.detailTextLabel?.textColor = UIColor.black // we need to reset this because a cell with red
        }
        
        cell.detailTextLabel!.text = dateFormatter.string(from: event.eventDate! as Date)
        cell.imageView!.image = finalImage
        cell.imageView!.layer.masksToBounds = true
        cell.imageView!.layer.cornerRadius = 5.0
        
        //-Lock the table image size to 45x45 with rounded corners
        let itemSize: CGSize = CGSize(width: 45, height: 45)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, CGFloat())
        let imageRect: CGRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
        cell.imageView!.image!.draw(in: imageRect)
        cell.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    
    //-Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }
    
    //-Set the table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier = "BeGoodTableCell"
        
        let event = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell
        
        //-This is the new configureCell method
        configureCell(cell, withEvent: event)
        
        return cell
    }
    
    
    //-If a table entry is selected, pull up the Event Details page
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
    //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        let controller =
        storyboard!.instantiateViewController(withIdentifier: "BeGoodShowViewController") as! BeGoodShowViewController

        controller.eventIndexPath = indexPath as IndexPath!
        controller.eventIndex = (indexPath as NSIndexPath).row
        
        self.navigationController!.pushViewController(controller, animated: true)

    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {

            switch (editingStyle) {
            case .delete:
                
                //-Get the event, then delete it from core data, delete related notifications, and remove any existing
                //-Calendar Event
                
                let event = fetchedResultsController.object(at: indexPath) 
                
                //-Delete the event notificaton
                if String(describing: event.eventDate!) > String(describing: Date()) { //...if event date is greater than the current date, remove the upcoming notification. If not, skip this routine.
                    
                    for notification in UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] { // loop through notifications...
                        if (notification.userInfo!["UUID"] as! String == String(describing: event.eventDate!)) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                            UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on title
                            break
                        }
                    }
                }
                
                //-Call Delete Calendar Event
                if event.textCalendarID == nil {
                    print("No calendar event:", event.textCalendarID)
                } else {
                    let eventStore = EKEventStore()
                    let eventID = event.textCalendarID!
                    let eventToRemove = eventStore.event(withIdentifier: eventID)
                
                    if (eventToRemove != nil) {
                        do {
                            try eventStore.remove(eventToRemove!, span: .thisEvent)
                        } catch {
                            print("Calender Event Removal Failed.")
                        }
                    }
                }
            
                //-Delete Main Event
                sharedContext.delete(event)
                CoreDataStackManager.sharedInstance().saveContext()

                //-Update the Archive any time this list of events is displayed.
                NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
                
            default:
                break
            }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
            
            switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                
            default:
                return
            }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                
            case .update:
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell?
                let event = controller.object(at: indexPath!) as! Events
                self.configureCell(cell!, withEvent: event)
                
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            }
    }
 
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    
    //-Create a New EVent
    func addEvent(){
        //let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BeGoodAddEventViewController") as! BeGoodAddEventViewController
        controller.editEventFlag = false
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Saving the array Helper.
    var eventsFilePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        print(url.appendingPathComponent("events").path)
        return url.appendingPathComponent("events").path
    }
    
    
    //-Alert Message function
    func welcomeAlertMessage(){
        DispatchQueue.main.async {
            let actionSheetController: UIAlertController = UIAlertController(title: "Welcome!", message: "Tap the '+' symbol to create Events", preferredStyle: .alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blue
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            //alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
            //alertContentView.backgroundColor = UIColor.green
            alertContentView.layer.cornerRadius = 12
            
            //-Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
        }
        //-After 3 second delay, close the Alert automatically
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.presentedViewController!.dismiss(animated: true, completion: nil);
        }
    }
}


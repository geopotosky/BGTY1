//
//  BeGoodPopoverViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//


import UIKit
import CoreData


enum AdaptiveMode{
    case Default
    case LandscapePopover
    case AlwaysPopover
}


class BeGoodPopoverViewController: UITableViewController, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBInspectable var popoverOniPhone:Bool = false
    @IBInspectable var popoverOniPhoneLandscape:Bool = true
    
    //-Global objects, properties & variables
    var events: Events!
    var eventIndexPath2: NSIndexPath!
    
    //-Info Alert variables
    var infoMessage: String!
    var infoTitle: String!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        //-Cancel button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(BeGoodPopoverViewController.tapCancel(_:)))
        //-Popover settings
        modalPresentationStyle = .Popover
        popoverPresentationController!.delegate = self
        self.preferredContentSize = CGSize(width:200,height:200)
    }
    
    
    func tapCancel(_ : UIBarButtonItem) {
        //-tap cancel
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.popoverPresentationController?.backgroundColor = UIColor.whiteColor()
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Events")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textEvent", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){

        let eventMenu = tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text
        if eventMenu == "To Do List" {
            
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TodoTableViewController") as! TodoTableViewController
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
            
            controller.eventIndexPath2 = eventIndexPath2
            controller.events = event
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.presentViewController(navController, animated: true, completion: nil)
            
        } else if eventMenu == "Budget Sheet" {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BudgetTableViewController") as! BudgetTableViewController
            
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
            
            controller.eventIndexPath2 = eventIndexPath2
            controller.events = event
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.presentViewController(navController, animated: true, completion: nil)
            
        } else if eventMenu == "Magic Wand Info" {
            
            //-Call the Info Alert message
            self.infoTitle = "What is the Magic Wand?"
            self.infoMessage = "The Magic Wand method, previously known as the MG Coefficient, is a very unique countdown element not available in any other countdown app. This fun method removes the 1st day of the event counter since the 1st day has already started, and removes the final day of the event counter since the last day can be considered part of the event day. 'Magic Wand OFF' displays the standard countdown values. 'Magic Wand ON' takes 2 days off the event countdown."
            self.InfoAlertMessage()
            
        } else if eventMenu == "About BGTY" {
            
            //-Call the Info Alert message
            self.infoTitle = "About Be Good To Yourself"
            self.infoMessage = "Version 1\r\r Be Good To Yourself” is an event tracker and countdown App. Users can add as many events as they want. Events are automatically saved after they are created/edited.  The app includes the ability to fully customize the event view, create To Do lists and budget sheets for each event. Users can add their event to their local calendar and share them with social media apps.\r\r Copyright(c) 2016 GeoWorld. All rights reserved."
            self.InfoAlertMessage()
        }
        
    }
    
    
    //-popover settings, adaptive for horizontal compact trait
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle{
        
        //-this method is only called by System when the screen has compact width
        
        //-return .None means we still want popover when adaptive on iPhone
        //-return .FullScreen means we'll get modal presetaion on iPhone
        
        switch(popoverOniPhone, popoverOniPhoneLandscape){
        case (true, _): //-always popover on iPhone
            return .None
            
        case (_, true): //-popover only on landscape on iPhone
            let size = PC.presentingViewController.view.frame.size
            if(size.width>320.0){ //landscape
                return .None
            }else{
                return .FullScreen
            }
            
        default: //-no popover on iPhone
            return .FullScreen
        }
    }
    
    
    func presentationController(_: UIPresentationController, viewControllerForAdaptivePresentationStyle _: UIModalPresentationStyle)
        -> UIViewController?{
            return UINavigationController(rootViewController: self)
    }
    
    
    //-Info Alert Message function
    func InfoAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController = UIAlertController(title: "\(self.infoTitle)", message: "\(self.infoMessage)", preferredStyle: .Alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blueColor()
            let subview = actionSheetController.view.subviews.first!
            let alertContentView = subview.subviews.first!
            alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
            alertContentView.layer.cornerRadius = 5;
            
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in

            self.dismissViewControllerAnimated(true, completion: {})
                
            }
            actionSheetController.addAction(okAction)
            
            
            //-Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }

}


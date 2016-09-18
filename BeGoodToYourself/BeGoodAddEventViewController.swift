//
//  BeGoodAddEventViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit
import CoreData
import EventKit


class BeGoodAddEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate{
    
    //-View Outlets
    @IBOutlet weak var datePickerLable: UILabel!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var flickrButton: UIButton!
    @IBOutlet weak var textFieldEvent: UITextField!
    @IBOutlet weak var toolbarObject: UIToolbar!
    @IBOutlet weak var adjustImageLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!

    
    //-Set the textfield delegates
    let eventTextDelegate = EventTextDelegate()
    
    //-Global objects, properties & variables
    var events: Events!
    var eventIndex2:Int!
    var eventIndexPath2: NSIndexPath!
    var todaysDate: NSDate!
    var editEventFlag: Bool!
    var currentEventDate: NSDate!
    var flickrImageURL: String!
    var flickrImage: UIImage!
    var calendarID: String!
    var changedEventImage: UIImage!

    
    //-Alert variable
    var alertMessage: String!
    
    //-Disney image based on flag (0-no pic, 1-library, 2-camera, 3-Flickr)
    var imageFlag: Int! = 0
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //-Set Navbar Title
        self.navigationItem.title = "Event Creator"
        //-Create Navbar Buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(BeGoodAddEventViewController.saveEvent))
        
        //-Disable SAVE button if creating new Event
        //-Enable SAVE button if editing existing Event
        //-Hide Adjust Image Text if Creating new Event
        //-View Adjust Image Text if editing existig Event
        if editEventFlag == true {
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.adjustImageLabel.hidden = false
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.adjustImageLabel.hidden = true
        }
        
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        
        
        //-ScrollView Min and Max settings
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        

        //-Adjust Image Text blur effects
        self.adjustImageLabel.textAlignment = NSTextAlignment.Center
        self.adjustImageLabel.layer.shadowColor = UIColor.blackColor().CGColor
        self.adjustImageLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.adjustImageLabel.layer.shadowRadius = 7.0
        self.adjustImageLabel.layer.shadowOpacity = 0.5
        self.adjustImageLabel.layer.masksToBounds = false
        
        
        //-Set the Image Size and Aspect Programmatically
        self.view.addBackground()
        
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(BeGoodAddEventViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
        
        //-Date Picker Formatting ----------------------------------------------------
        
        let dateFormatter = NSDateFormatter()
        
        self.todaysDate = NSDate()
        let timeZone = NSTimeZone(name: "Local")
        
        dateFormatter.timeZone = timeZone
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        
        //-----------------------------------------------------------------------------
        
        
        //-Set starting textfield default values
        self.textFieldEvent.text = "Enter Event Description"
        self.textFieldEvent.textAlignment = NSTextAlignment.Center
        
        //-Textfield delegate values
        self.textFieldEvent.delegate = eventTextDelegate
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        //-Set Values Based on New or Existing Event
        if editEventFlag == false {
            //-Load default values for new event
            self.tempImage.hidden = false
            currentEventDate = NSDate()
            
            
        } else {
            
            self.tempImage.hidden = true
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
            
            //-Add Selected Meme attributes and populate Editor fields
            self.textFieldEvent.text = event.textEvent
            imageViewPicker.image = UIImage(data: event.eventImage!)
            currentEventDate = event.eventDate
            calendarID = event.textCalendarID
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            let strDate = dateFormatter.stringFromDate(currentEventDate)
            datePickerLable.text = strDate
            
        }
        
    }
    
    
    //-Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        //-Recognize the Flickr image request
        if imageFlag == 3 {
            
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.adjustImageLabel.hidden = false
            self.imageViewPicker.image = flickrImage
            
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        if currentEventDate != nil {
            let strDate = dateFormatter.stringFromDate(currentEventDate)
            datePickerLable.text = strDate
            
        }
        
        //-Disable the CAMERA if you are using a simulator without a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
    }
    
    //-Perform when view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()

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

    //-Scrolling an Image Movements
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        //self.adjustImageLabel.hidden = true
        return self.imageViewPicker
    }

    
    //-Pick Event Date
    @IBAction func pickEventDate(sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodPickDateViewController") as! BeGoodPickDateViewController
        controller.editEventFlag2 = editEventFlag
        controller.currentEventDate = self.currentEventDate
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //-Button to Pick an image from the library
    @IBAction func PickAnImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //-Select an image for the Event from your Camera Roll
    func imagePickerController(imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            
            if let eventImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageViewPicker.image = eventImage
                self.adjustImageLabel.hidden = false
                self.tempImage.hidden = true
                
                //-Reset the ScrollView to original scale
                self.scrollView.zoomScale = 1.0
                
                
            }
        
            //-Enable the Right Navbar Button
            self.navigationItem.rightBarButtonItem?.enabled = true
        
            self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    
    //-Cancel the picked image
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //-Select an image by taking a Picture
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imageFlag = 2
        self.tempImage.hidden = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    //-Call the Flickr VC
    @IBAction func getFlickrImage(sender: UIButton) {

        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodFlickrViewController") as! BeGoodFlickrViewController
        controller.editEventFlag2 = editEventFlag
        controller.eventIndexPath2 = self.eventIndexPath2
        controller.currentImage = imageViewPicker.image
        self.tempImage.hidden = true
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Dismissing the keyboard methods
    
    func addKeyboardDismissRecognizer() {
        //-Add the recognizer to dismiss the keyboard
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        //-Remove the recognizer to dismiss the keyboard
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        //-End editing here
        self.view.endEditing(true)
    }

    
    //-Create the adjusted Event Image
    func createSnapshotOfView() -> UIImage {
        
        //-Hide toolbar
        toolbarObject.hidden = true
        self.navigationController!.navigationBar.hidden = true
        datePickerLable.hidden = true
        datePickerButton.hidden = true
        textFieldEvent.hidden = true
        adjustImageLabel.hidden = true
        
        let rect: CGRect = view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        view.layer.renderInContext(context)
        let capturedScreen: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let shareEventImage: UIImage = UIImage(CGImage: capturedScreen.CGImage!, scale: 1.0, orientation: .Up)
        
        //-UnHide toolbar
        toolbarObject.hidden = false
        self.navigationController!.navigationBar.hidden = false
        datePickerLable.hidden = false
        datePickerButton.hidden = false
        textFieldEvent.hidden = false
        
        return shareEventImage
    }
    
    
    //-Save the Event method
    func saveEvent() {
        
        //-Create the adjusted event image.
        self.changedEventImage = createSnapshotOfView()
        
        let eventImage = UIImageJPEGRepresentation(self.changedEventImage, 100)
        
        //-Verify Selected Date is greater than current date before saving
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss a"
        print(dateFormatter.stringFromDate(self.currentEventDate))
        print(dateFormatter.stringFromDate(NSDate()))
        
        //-If the edit event flag is set to true, save a existing event
        if editEventFlag == true {
            
            if textFieldEvent.text == "" || textFieldEvent.text == "Enter Event Description"{
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
                
            } else
                //-Verify Selected Date is greater than current date before saving
                
                if dateFormatter.stringFromDate(self.currentEventDate) <= dateFormatter.stringFromDate(NSDate()){
                    self.alertMessage = "Please Verify the Event Date is Greater Than the Current Date"
                    self.textAlertMessage()
                } else {
            
                    //-Get the original event, then delete it from core data, delete related notifications, and remove any
                    //-existing Calendar Event
                
                    let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
                
                    //-Delete the original event notificaton
                    if String(event.eventDate!) > String(NSDate()) { //...if event date is greater than the current date, remove the upcoming notification. If not, skip this routine.
                    
                        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] { // loop through notifications...
                            if (notification.userInfo!["UUID"] as! String == String(event.eventDate!)) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on title
                                break
                            }
                        }
                    }
                
                //-Call Delete original Calendar Event
                if event.textCalendarID != nil {
                    let eventStore = EKEventStore()
                    let eventID = event.textCalendarID!
                    let eventToRemove = eventStore.eventWithIdentifier(eventID)
                    
                    if (eventToRemove != nil) {
                        do {
                            try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
                        } catch {
                            self.alertMessage = "Calendar Event Removal Failed."
                            self.textAlertMessage()
                        }
                    }
                }
                //- Do nothing if no events are found for deletion
                
                    
                //-Update selected event
                event.eventDate = self.currentEventDate
                event.textEvent = textFieldEvent.text!
                event.eventImage = eventImage
                event.textCalendarID = calendarID
                self.sharedContext.refreshObject(event, mergeChanges: true)
                CoreDataStackManager.sharedInstance().saveContext()
                
                //-Create a corresponding local notification
                dateFormatter.dateFormat = "MMM dd 'at' h:mm a" // example: "Jan 01 at 12:00 PM"

                let notification = UILocalNotification()
                notification.alertBody = "Event \(textFieldEvent.text!) - on \"\(dateFormatter.stringFromDate(self.currentEventDate))\" is Overdue" // text that will be displayed in the notification
                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                notification.fireDate = self.currentEventDate // Event item due date (when notification will be fired)
                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                notification.userInfo = ["UUID": String(self.currentEventDate)]
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
            
                //-Pass event index info to Show scene
                let controller = self.navigationController!.viewControllers[1] as! BeGoodShowViewController
                controller.editEventFlag = true
                controller.eventIndexPath = self.eventIndexPath2
                controller.eventIndex = self.eventIndex2
                    
                self.navigationController?.popViewControllerAnimated(true)
            }
            
        //-If the edit event flag is set to false, save a new event
        } else {
            if textFieldEvent.text == "" || textFieldEvent.text == "Enter Event Description" {
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
            } else
                //-Verify Selected Date is greater than current date before saving
                if dateFormatter.stringFromDate(self.currentEventDate) <= dateFormatter.stringFromDate(NSDate()){
                    self.alertMessage = "Please Verify the Event Date is Greater Than the Current Date"
                    self.textAlertMessage()
                    
                }else {
                
                
                    //-Save new event
                    let _ = Events(eventDate: self.currentEventDate, textEvent: textFieldEvent.text!, eventImage: eventImage, textCalendarID: nil, context: sharedContext)
            
                    //-Save the shared context, using the convenience method in the CoreDataStackManager
                    CoreDataStackManager.sharedInstance().saveContext()
                
                    //-Create a corresponding local notification
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MMM dd 'at' h:mm a" // example: "Jan 01 at 12:00 PM"
                
                    let notification = UILocalNotification()
                    notification.alertBody = "Event \(textFieldEvent.text!) - on \"\(dateFormatter.stringFromDate(self.currentEventDate))\" is Overdue" // text that will be displayed in the notification
                    notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                    notification.fireDate = self.currentEventDate // todo item due date (when notification will be fired)
                    notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                    notification.userInfo = ["UUID": String(self.currentEventDate)]
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
            
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
    }
    
    
    //-Alert Message function
    func textAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController = UIAlertController(title: "Alert!", message: "\(self.alertMessage)", preferredStyle: .Alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blueColor()
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
            alertContentView.layer.cornerRadius = 5;
            
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                
            }
            actionSheetController.addAction(okAction)
            
            //-Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    
    //-Saving the array Helper.
    var eventsFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        //print(url.URLByAppendingPathComponent("events").path!)
        return url.URLByAppendingPathComponent("events").path!
    }
    
}

//-Process to Set the Image Size & Aspect Programmatically
extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }}




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
    //var events: [Events]!
    var eventIndex2:Int!
    var eventIndexPath2: IndexPath!
    var todaysDate: Date!
    var editEventFlag: Bool!
    var currentEventDate: Date!
    var flickrImageURL: String!
    var flickrImage: UIImage!
    var calendarID: String!
    var changedEventImage: UIImage!
    //var section: Int!
    

    
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(BeGoodAddEventViewController.saveEvent))
        
        //-Disable SAVE button if creating new Event
        //-Enable SAVE button if editing existing Event
        //-Hide Adjust Image Text if Creating new Event
        //-View Adjust Image Text if editing existig Event
        if editEventFlag == true {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.adjustImageLabel.isHidden = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.adjustImageLabel.isHidden = true
        }
        
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.isHidden = true
        
        
        //-ScrollView Min and Max settings
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        

        //-Adjust Image Text blur effects
        self.adjustImageLabel.textAlignment = NSTextAlignment.center
        self.adjustImageLabel.layer.shadowColor = UIColor.black.cgColor
        self.adjustImageLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.adjustImageLabel.layer.shadowRadius = 7.0
        self.adjustImageLabel.layer.shadowOpacity = 0.5
        self.adjustImageLabel.layer.masksToBounds = false
        
        
        //-Set the Image Size and Aspect Programmatically
        self.view.addBackground()
        
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(BeGoodAddEventViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
        
        //-Date Picker Formatting ----------------------------------------------------
        
        let dateFormatter = DateFormatter()
        
        self.todaysDate = Date()
        let timeZone = TimeZone(identifier: "Local")
        dateFormatter.timeZone = timeZone
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        
        //-----------------------------------------------------------------------------
        
        
        //-Set starting textfield default values
        self.textFieldEvent.text = "Enter Event Description"
        self.textFieldEvent.textAlignment = NSTextAlignment.center
        
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
            //tempImage.isHidden = false
            currentEventDate = Date()
            
            
        } else {
            tempImage.isHidden = true
            //print(tempImage.isHidden)
            let event = fetchedResultsController.object(at: eventIndexPath2) 
            
            //-Add Selected Meme attributes and populate Editor fields
            self.textFieldEvent.text = event.textEvent
            imageViewPicker.image = UIImage(data: event.eventImage!)
            currentEventDate = event.eventDate
            calendarID = event.textCalendarID
            
            let dateFormatter = DateFormatter()
            let timeZone = TimeZone(identifier: "Local")
            dateFormatter.timeZone = timeZone
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            let strDate = dateFormatter.string(from: currentEventDate)
            datePickerLable.text = strDate
            
        }
        
    }
    
    
    //-Perform when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        //-Recognize the Flickr image request
        if imageFlag == 3 {
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.adjustImageLabel.isHidden = false
            self.imageViewPicker.image = flickrImage
            //self.tempImage.isHidden = true
            
        } else {
            //self.tempImage.isHidden = false
        }
        
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone(identifier: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        if currentEventDate != nil {
            let strDate = dateFormatter.string(from: currentEventDate)
            datePickerLable.text = strDate
            
        }
        
        //-Disable the CAMERA if you are using a simulator without a camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
    }
    
    //-Perform when view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()

    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController<Events> = {
        
        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        //fetchRequest.predicate = NSPredicate(format: "events == %@", self.events);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()

    //-Scrolling an Image Movements
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        //self.adjustImageLabel.hidden = true
        return self.imageViewPicker
    }

    
    //-Pick Event Date
    @IBAction func pickEventDate(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BeGoodPickDateViewController") as! BeGoodPickDateViewController
        controller.editEventFlag2 = editEventFlag
        controller.currentEventDate = self.currentEventDate
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //-Button to Pick an image from the library
    @IBAction func PickAnImage(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //-Select an image for the Event from your Camera Roll
    func imagePickerController(_ imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any]){
            
            if let eventImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageViewPicker.image = eventImage
                self.adjustImageLabel.isHidden = false
                self.tempImage.isHidden = true
                
                //-Reset the ScrollView to original scale
                self.scrollView.zoomScale = 1.0
                
                
            }
        
            //-Enable the Right Navbar Button
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        
            self.dismiss(animated: true, completion: nil)
        
    }

    
    
    //-Cancel the picked image
    func imagePickerControllerDidCancel(_ imagePicker: UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //-Select an image by taking a Picture
    @IBAction func pickAnImageFromCamera (_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imageFlag = 2
        //self.tempImage.isHidden = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    //-Call the Flickr VC
    @IBAction func getFlickrImage(_ sender: UIButton) {

        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BeGoodFlickrViewController") as! BeGoodFlickrViewController
        controller.editEventFlag2 = editEventFlag
        controller.eventIndexPath2 = self.eventIndexPath2
        controller.currentImage = imageViewPicker.image
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
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        //-End editing here
        self.view.endEditing(true)
    }

    
    //-Create the adjusted Event Image
    func createSnapshotOfView() -> UIImage {
        
        //-Hide toolbar
        toolbarObject.isHidden = true
        self.navigationController!.navigationBar.isHidden = true
        datePickerLable.isHidden = true
        datePickerButton.isHidden = true
        textFieldEvent.isHidden = true
        adjustImageLabel.isHidden = true
        
        let rect: CGRect = view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        view.layer.render(in: context)
        let capturedScreen: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let shareEventImage: UIImage = UIImage(cgImage: capturedScreen.cgImage!, scale: 1.0, orientation: .up)
        
        //-UnHide toolbar
        toolbarObject.isHidden = false
        self.navigationController!.navigationBar.isHidden = false
        datePickerLable.isHidden = false
        datePickerButton.isHidden = false
        textFieldEvent.isHidden = false
        
        return shareEventImage
    }
    
    
    //-Save the Event method
    func saveEvent() {

        //-Create the adjusted event image.
        self.changedEventImage = createSnapshotOfView()
        
        let eventImage = UIImageJPEGRepresentation(self.changedEventImage, 100)
        
        //-Verify Selected Date is greater than current date before saving
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss a"
        //print(dateFormatter.string(from: self.currentEventDate))
        //print(dateFormatter.string(from: Date()))
        
        //-If the edit event flag is set to true, save a existing event
        if editEventFlag == true {
            
            if textFieldEvent.text == "" || textFieldEvent.text == "Enter Event Description"{
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
                
            } else
                //-Verify Selected Date is greater than current date before saving
                
                if dateFormatter.string(from: self.currentEventDate) <= dateFormatter.string(from: Date()){
                    self.alertMessage = "Please Verify the Event Date is Greater Than the Current Date"
                    self.textAlertMessage()
                } else {
            
                    //-Get the original event, then delete it from core data, delete related notifications, and remove any
                    //-existing Calendar Event
                
                    let event = fetchedResultsController.object(at: eventIndexPath2) 
                
                    //-Delete the original event notificaton
                    if String(describing: event.eventDate!) > String(describing: Date()) { //...if event date is greater than the current date, remove the upcoming notification. If not, skip this routine.
                    
                        for notification in UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] { // loop through notifications...
                            if (notification.userInfo!["UUID"] as! String == String(describing: event.eventDate!)) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                                UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on title
                                break
                            }
                        }
                    }
                
                //-Call Delete original Calendar Event
                if event.textCalendarID != nil {
                    let eventStore = EKEventStore()
                    let eventID = event.textCalendarID!
                    let eventToRemove = eventStore.event(withIdentifier: eventID)
                    
                    if (eventToRemove != nil) {
                        do {
                            try eventStore.remove(eventToRemove!, span: .thisEvent)
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
                self.sharedContext.refresh(event, mergeChanges: true)
                CoreDataStackManager.sharedInstance().saveContext()
                
                //-Create a corresponding local notification
                dateFormatter.dateFormat = "MMM dd 'at' h:mm a" // example: "Jan 01 at 12:00 PM"

                let notification = UILocalNotification()
                notification.alertBody = "Event \(textFieldEvent.text!) - on \"\(dateFormatter.string(from: self.currentEventDate))\" is Overdue" // text that will be displayed in the notification
                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                notification.fireDate = self.currentEventDate // Event item due date (when notification will be fired)
                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                notification.userInfo = ["UUID": String(describing: self.currentEventDate)]
                UIApplication.shared.scheduleLocalNotification(notification)
                
            
                //-Pass event index info to Show scene
                let controller = self.navigationController!.viewControllers[1] as! BeGoodShowViewController
                controller.editEventFlag = true
                controller.eventIndexPath = self.eventIndexPath2
                controller.eventIndex = self.eventIndex2
                    
                self.navigationController!.popViewController(animated: true)
            }
            
        //-If the edit event flag is set to false, save a new event
        } else {
            if textFieldEvent.text == "" || textFieldEvent.text == "Enter Event Description" {
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
            } else
                //-Verify Selected Date is greater than current date before saving
                if dateFormatter.string(from: self.currentEventDate) <= dateFormatter.string(from: Date()){
                    self.alertMessage = "Please Verify the Event Date is Greater Than the Current Date"
                    self.textAlertMessage()
                    
                }else {
                
                
                    //-Save new event
                    let _ = Events(eventDate: self.currentEventDate, textEvent: textFieldEvent.text!, eventImage: eventImage, textCalendarID: nil, context: sharedContext)
            
                    //-Save the shared context, using the convenience method in the CoreDataStackManager
                    CoreDataStackManager.sharedInstance().saveContext()
                
                    //-Create a corresponding local notification
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd 'at' h:mm a" // example: "Jan 01 at 12:00 PM"
                
                    let notification = UILocalNotification()
                    notification.alertBody = "Event \(textFieldEvent.text!) - on \"\(dateFormatter.string(from: self.currentEventDate))\" is Overdue" // text that will be displayed in the notification
                    notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                    notification.fireDate = self.currentEventDate // todo item due date (when notification will be fired)
                    notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                    notification.userInfo = ["UUID": String(describing: self.currentEventDate)]
                    UIApplication.shared.scheduleLocalNotification(notification)
                
            
                    self.navigationController!.popViewController(animated: true)
                }
            }
    }
    
    
    //-Alert Message function
    func textAlertMessage(){
        DispatchQueue.main.async {
            let actionSheetController = UIAlertController(title: "Alert!", message: "\(self.alertMessage!)", preferredStyle: .alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blue
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
            alertContentView.layer.cornerRadius = 12
            
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
                
            }
            actionSheetController.addAction(okAction)
            
            //-Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    
    //-Saving the array Helper.
    var eventsFilePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        //print(url.URLByAppendingPathComponent("events").path!)
        return url.appendingPathComponent("events").path
    }
    
}

//-Process to Set the Image Size & Aspect Programmatically
extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
    }}




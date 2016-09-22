//
//  BeGoodShowViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//


import UIKit
import CoreData
import EventKit


class BeGoodShowViewController : UIViewController, NSFetchedResultsControllerDelegate {
    
    //-View Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var deleteEventButton: UIBarButtonItem!
    @IBOutlet weak var editEventButton: UIBarButtonItem!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var untilEventSelector: UISegmentedControl!
    @IBOutlet weak var mgFactorLabel: UILabel!
    @IBOutlet weak var shareEventButton: UIToolbar!
    @IBOutlet weak var eventCalendarButton: UIButton!
    @IBOutlet weak var toolbarObject: UIToolbar!
    @IBOutlet weak var secondsTickerLabel: UILabel!
    @IBOutlet weak var secondsWordLabel: UILabel!
    @IBOutlet weak var minutesTickerLabel: UILabel!
    @IBOutlet weak var minutesWordLabel: UILabel!
    @IBOutlet weak var hoursTickerLabel: UILabel!
    @IBOutlet weak var hoursWordLabel: UILabel!
    @IBOutlet weak var daysTickerLabel: UILabel!
    @IBOutlet weak var daysWordLabel: UILabel!
    @IBOutlet weak var untilEventText2: UITextField!
    @IBOutlet weak var untilEventText3: UITextField!
    @IBOutlet weak var magicButton: UIButton!

    //-Global objects, properties & variables
    var events: [Events]!

    var eventIndex:Int!
    var eventIndexPath: IndexPath!
    var editEventFlag: Bool!
    var mgFactorValue: Int! = 0
    var shareEventImage: UIImage!
    
    //-Time Related Variables
    var timeAtPress = Date()
    var currentDateWithOffset = Date()
    var count: Int!
    var pickEventDate: Date!
    var tempEventDate: Date!
    var durationSeconds: Int!
    var durationMinutes: Int!
    var durationHours: Int!
    var durationDays: Int!
    var durationWeeks: Int!
    var durationMonths: Int!
    
    //-Alert variables
    var alertMessage: String!
    var alertTitle: String!
    
    //-Event Text Font Attributes
    let eventTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: 30)!,
        NSStrokeWidthAttributeName : -2.0
    ] as [String : Any]
    let untilTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: 20)!,
        NSStrokeWidthAttributeName : -2.0
    ] as [String : Any]
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Change toolbar color
        
        //-Manage Top and Bottom bar colors
        //-Green Bars
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        self.navigationController!.navigationBar.isTranslucent = false
        
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.isHidden = true
        
        //-Hide the "Event Ended" message
        countDownLabel.isHidden = true
        
        //-Main UNTIL Text blur effects
        self.untilEventText2.textAlignment = NSTextAlignment.center
        self.untilEventText2.layer.shadowColor = UIColor.black.cgColor
        self.untilEventText2.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.untilEventText2.layer.shadowRadius = 7.0
        self.untilEventText2.layer.shadowOpacity = 0.5
        self.untilEventText2.layer.masksToBounds = false

        //-UNTIL Description blur effects
        self.untilEventText3.textAlignment = NSTextAlignment.center
        self.untilEventText3.layer.shadowColor = UIColor.black.cgColor
        self.untilEventText3.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.untilEventText3.layer.shadowRadius = 7.0
        self.untilEventText3.layer.shadowOpacity = 0.5
        self.untilEventText3.layer.masksToBounds = false

        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        
        //-Start Countdown Timer routine
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BeGoodShowViewController.update), userInfo: nil, repeats: true)
        
        let event = fetchedResultsController.object(at: eventIndexPath)
        
        //-Set the initial time values
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSince(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Call the "Until Date" selector method
        segmentPicked(untilEventSelector)
        
    }
    
    //-Perform when view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-UnHide the main ticker
        secondsTickerLabel.isHidden = false
        secondsWordLabel.isHidden = false
        minutesTickerLabel.isHidden = false
        minutesWordLabel.isHidden = false
        hoursTickerLabel.isHidden = false
        hoursWordLabel.isHidden = false
        daysTickerLabel.isHidden = false
        daysWordLabel.isHidden = false
        countDownLabel.isHidden = true
        
        
        //-Set Magic Wand button to OFF
        mgFactorValue = 0
        mgFactorLabel.text = "OFF"
        
        let event = fetchedResultsController.object(at: eventIndexPath)
        
        let dateFormatter = DateFormatter()
        let date = event.eventDate
        let timeZone = TimeZone(identifier: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.long //Set date style
        
        let localDate = dateFormatter.string(from: date!)
        self.eventDate.text = "Event Date: " + localDate
        
        //-Reset Event Selector Values to TRUE after update until re-evaluated
        untilEventSelector.setEnabled(true, forSegmentAt: 0)
        untilEventSelector.setEnabled(true, forSegmentAt: 1)
        untilEventSelector.setEnabled(true, forSegmentAt: 2)
        untilEventSelector.setEnabled(true, forSegmentAt: 3)
        
        //-Reset the initial time values
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSince(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Call the "Until Date" selector method
        segmentPicked(untilEventSelector)
        
        //-Reset Until Days value
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let tempText1 = numberFormatter.string(from: self.durationDays as NSNumber)!
        if self.durationDays == 1 {
            untilEventText2.text = ("Only \(tempText1) Day")
        }
        else {
            untilEventText2.text = ("Only \(tempText1) Days")
        }
        
        let finalImage = UIImage(data: event.eventImage!)
        self.imageView!.image = finalImage
        self.untilEventText3.text = "until " + event.textEvent!

        //-Call the main "until" setup routine
        untilCounterStart()

    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<Events> = {
        
        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
        
    
    //-Set the "until" dynamic text based on segment selection
    @IBAction func segmentPicked(_ sender: UISegmentedControl) {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        //-Segment Control style changes
        sender.layer.cornerRadius = 7.0
        sender.layer.borderColor = UIColor.blue.cgColor
        sender.layer.borderWidth = 1.0
        sender.layer.masksToBounds = true
        sender.clipsToBounds = true
        
        switch untilEventSelector.selectedSegmentIndex {

        case 0:
            let tempText1 = numberFormatter.string(from: self.durationWeeks as NSNumber)!
            if self.durationWeeks < 2 {
                untilEventText2.text = ("Only \(tempText1) Week")
            } else {
                untilEventText2.text = ("Only \(tempText1) Weeks")
            }
        case 1:
            let tempText1 = numberFormatter.string(from: self.durationDays as NSNumber)!
            if self.durationDays == 1 {
                untilEventText2.text = ("Only \(tempText1) Day")
            }
            else {
                untilEventText2.text = ("Only \(tempText1) Days")
            }
        case 2:
            let tempText1 = numberFormatter.string(from: self.durationHours as NSNumber)!
            if self.durationHours < 2 {
                untilEventText2.text = ("Only \(tempText1) Hour")
            } else {
                untilEventText2.text = ("Only \(tempText1) Hours")
            }
        case 3:
            let tempText1 = numberFormatter.string(from: self.durationMinutes as NSNumber)!
            if self.durationMinutes < 2 {
                untilEventText2.text = ("Only \(tempText1) Minute")
            } else {
                untilEventText2.text = ("Only \(tempText1) Minutes")
            }
        case 4:
            let tempText1 = numberFormatter.string(from: self.durationSeconds as NSNumber)!
            if self.durationSeconds < 2 {
                untilEventText2.text = ("Only \(tempText1) Second")
            } else {
                untilEventText2.text = ("Only \(tempText1) Seconds")
            }
        default:
            break
        }
    }
    
    
    //-Edit the selected event
    @IBAction func editEvent(_ sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BeGoodAddEventViewController") as! BeGoodAddEventViewController

        controller.eventIndexPath2 = eventIndexPath
        controller.eventIndex2 = eventIndex
        controller.editEventFlag = true

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Delete the selected event
    @IBAction func deleteEvent(_ sender: UIBarButtonItem) {
        
        //-Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete the Event?", preferredStyle: .alert)
        
        //-Update alert colors and attributes
        actionSheetController.view.tintColor = UIColor.blue
        let subview = actionSheetController.view.subviews.first! 
        let alertContentView = subview.subviews.first! 
        //alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        alertContentView.layer.cornerRadius = 12
        
        //-Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        
        //-Create and add the Delete Event action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete Event", style: .default) { action -> Void in
            
            //-Get the event, then delete it from core data, delete related notifications, and remove any existing
            //-Calendar Event
            
            let event = self.fetchedResultsController.object(at: self.eventIndexPath) 
            
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
            self.sharedContext.delete(event)
            CoreDataStackManager.sharedInstance().saveContext()

            self.navigationController!.popViewController(animated: true)
        }
        actionSheetController.addAction(deleteAction)
        
        //-Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    //-Update Countdown Time Viewer
    func update() {
        
        if(count > 0)
        {
            count = count - 1
            
            let minutes:Int = (count / 60)
            let hours:Int = ((count / 60) / 60) % 24
            let days:Int = ((count / 60) / 60) / 24
            let seconds:Int = count - (minutes * 60)
            let minutes2:Int = (count / 60) % 60
            
            let timerOutput = String(format: "%5d Days %2d:%2d:%02d", days, hours, minutes2, seconds) as String
            countDownLabel.text = timerOutput as String
            
            secondsTickerLabel.text = String(format: "%02d", seconds)
            minutesTickerLabel.text = String(format: "%02d", minutes2)
            hoursTickerLabel.text = String(format: "%02d", hours)
            daysTickerLabel.text = String(days)
            
        }
        else{
            //-Hide the main ticker and show the "Event Ended" message
            secondsTickerLabel.isHidden = true
            secondsWordLabel.isHidden = true
            minutesTickerLabel.isHidden = true
            minutesWordLabel.isHidden = true
            hoursTickerLabel.isHidden = true
            hoursWordLabel.isHidden = true
            daysTickerLabel.isHidden = true
            daysWordLabel.isHidden = true
            countDownLabel.isHidden = false
            
            countDownLabel.text = "Event Has Past"
        }
        
        //------------------- UNTIL TICKER -----------------------------
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        switch untilEventSelector.selectedSegmentIndex {
            
        case 0:
            let tempText1 = numberFormatter.string(from: self.durationWeeks as NSNumber)!
            if self.durationWeeks < 2 {
                untilEventText2.text = ("Only \(tempText1) Week")
            } else {
                untilEventText2.text = ("Only \(tempText1) Weeks")
            }
        case 1:
            let tempText1 = numberFormatter.string(from: self.durationDays as NSNumber)!
            if self.durationDays == 1 {
                untilEventText2.text = ("Only \(tempText1) Day")
            } else {
                untilEventText2.text = ("Only \(tempText1) Days")
            }
        case 2:
            let tempText1 = numberFormatter.string(from: self.durationHours as NSNumber)!
            if self.durationHours < 2 {
                untilEventText2.text = ("Only \(tempText1) Hour")
            } else {
                untilEventText2.text = ("Only \(tempText1) Hours")
            }
        case 3:
            let tempText1 = numberFormatter.string(from: self.durationMinutes as NSNumber)!
            if self.durationMinutes < 2 {
                untilEventText2.text = ("Only \(tempText1) Minute")
            } else {
                untilEventText2.text = ("Only \(tempText1) Minutes")
            }
        case 4:
            let tempText1 = numberFormatter.string(from: self.durationSeconds as NSNumber)!
            if self.durationSeconds < 2 {
                untilEventText2.text = ("Only \(tempText1) Second")
            } else {
                untilEventText2.text = ("Only \(tempText1) Seconds")
            }
        default:
            break
        }
        
        //-Until Counter Updater
        durationSeconds = count
        durationMinutes = count / 60
        durationHours = (count / 60) / 60
        durationDays = ((count / 60) / 60) / 24
        durationWeeks = (((count / 60) / 60) / 24) / 7
    
    }
    
    
    //-Setup the "untils" based on the current date and event date for the first time
    func untilCounterStart(){

        let event = fetchedResultsController.object(at: eventIndexPath)
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSince(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Disable Magic Wand button is days < 2
        if durationDays < 2 {
            magicButton.isEnabled = false
        } else {
            magicButton.isEnabled = true
        }
        
        //-Disable Segment button if value = 0
        if durationWeeks == 0 {
            untilEventSelector.setEnabled(false, forSegmentAt: 0)
        }
        if durationDays == 0 {
            untilEventSelector.setEnabled(false, forSegmentAt: 1)
        }
        if durationHours == 0 {
            untilEventSelector.setEnabled(false, forSegmentAt: 2)
        }
        if durationMinutes == 0 {
            untilEventSelector.setEnabled(false, forSegmentAt: 3)
        }
        
        //-Set the default segment value (days)
        let tempText1 = String(stringInterpolationSegment: self.durationDays)
        
        //-Check for end of event
        if tempText1 == "-1" {
            self.untilEventText2.text = "ZERO Days"
        }
        
        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds
        
        
    }
    
    
    //-The Magic Wand is a special method which removes 1 day from the front of the vacation
    //-and 1 day from the back. After all, does anybody really count those days when your planning? :-)
    @IBAction func mgFactor(_ sender: UIButton) {
        
        //-Set the Magic Factor (172800 = 2 days in seconds) and update the button label
        if mgFactorValue == 0 {
            mgFactorValue = 172800
            mgFactorLabel.text = "ON"
            
        }
        else {
            mgFactorValue = 0
            mgFactorLabel.text = "OFF"
        }
        
        let event = fetchedResultsController.object(at: eventIndexPath)
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSince(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime) - mgFactorValue
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7

        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds

    }

    
    //-Call the Popover Menu
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        switch(segue.identifier!){
        case "eventMenu":
            let popoverController = (segue.destination as? BeGoodPopoverViewController)
            let event = fetchedResultsController.object(at: eventIndexPath)
            popoverController!.eventIndexPath2 = eventIndexPath
            popoverController!.events = event
            break
        default:
            break
        }
    }
    
} //- END main class



//-Separate the Sharing and Calendar Method to better organize the code

extension BeGoodShowViewController {
    
    func createSnapshotOfView() -> UIImage {
        
        //-Hide toolbar
        toolbarObject.isHidden = true
        untilEventSelector.isHidden = true
        mgFactorLabel.isHidden = true
        
        let rect: CGRect = view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        view.layer.render(in: context)
        let capturedScreen: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let shareEventImage: UIImage = UIImage(cgImage: capturedScreen.cgImage!, scale: 1.0, orientation: .up)
        
        //-UnHide toolbar
        toolbarObject.isHidden = false
        untilEventSelector.isHidden = false
        mgFactorLabel.isHidden = false

        
        return shareEventImage
    }
    
    
    //-Share the generated event image with other apps
    @IBAction func shareEvent(_ sender: UIBarButtonItem) {
        
        //-Create a event image, pass it to the activity view controller.
        self.shareEventImage = createSnapshotOfView()
        
        let activityVC = UIActivityViewController(activityItems: [self.shareEventImage!], applicationActivities: nil)
        
        activityVC.excludedActivityTypes =  [
            UIActivityType.saveToCameraRoll
            //UIActivityTypePostToTwitter,
            //UIActivityTypePostToFacebook,
            //UIActivityTypePostToWeibo,
            //UIActivityTypeMessage,
            //UIActivityTypeMail,
            //UIActivityTypePrint,
            //UIActivityTypeCopyToPasteboard,
            //UIActivityTypeAssignToContact,
            //UIActivityTypeSaveToCameraRoll,
            //UIActivityTypeAddToReadingList,
            //UIActivityTypePostToFlickr,
            //UIActivityTypePostToVimeo,
            //UIActivityTypePostToTencentWeibo
        ]
        
        activityVC.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(activityVC, animated: true, completion: nil)
    }

    
    // Responds to button to add event. This checks that we have permission first, before adding the event
    @IBAction func addCalendarEvent(_ sender: UIButton) {
        let eventStore = EKEventStore()
    
        let event = fetchedResultsController.object(at: eventIndexPath) 
        
        //-Set the selected event start date & time
        let startDate = event.eventDate
        
        //-2 hours ahead for endtime
        let endDate = startDate!.addingTimeInterval(2 * 60 * 60)
    
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                self.insertEvent(eventStore, startDate: startDate!, endDate: endDate)
            })
        } else {
            self.insertEvent(eventStore, startDate: startDate!, endDate: endDate)
        }
    }

    
    // Creates an event in the EKEventStore. The method assumes the eventStore is created and accessible
        func insertEvent(_ eventStore: EKEventStore, startDate: Date, endDate: Date) {
            
            let event = fetchedResultsController.object(at: eventIndexPath) 
            
            //-Create Calendar Event
            let calendarEvent = EKEvent(eventStore: eventStore)
            calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
            
            calendarEvent.title = event.textEvent!
            calendarEvent.startDate = startDate
            calendarEvent.endDate = endDate
            
            
            //-Set alert for 1 hour prior to Event
            let alarm = EKAlarm(relativeOffset: -3600.0)
            calendarEvent.addAlarm(alarm)
            
            do {
                try eventStore.save(calendarEvent, span: .thisEvent)
                //-ReSave the event with the calendar Identifier
                event.textCalendarID = calendarEvent.eventIdentifier
                self.sharedContext.refresh(event, mergeChanges: true)
                CoreDataStackManager.sharedInstance().saveContext()
                
                
                //-Call Alert message
                self.alertTitle = "SUCCESS!"
                self.alertMessage = "Event added to your Calendar"
                self.calendarAlertMessage()
            } catch {
                //-Call Alert message
                self.alertTitle = "NOTICE"
                self.alertMessage = "One of your Calendars may be restricted. Please check to see if the Calendar event is added or allow access to add events."
                self.calendarAlertMessage()
            }
        }
    
    
    //-Alert Message function
    func calendarAlertMessage(){
        DispatchQueue.main.async {
            let actionSheetController = UIAlertController(title: "\(self.alertTitle!)", message: "\(self.alertMessage!)", preferredStyle: .alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blue
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            //alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
            //alertContentView.backgroundColor = UIColor.green
            alertContentView.layer.cornerRadius = 12
            
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
                
            }
            actionSheetController.addAction(okAction)
            
            //-Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
}


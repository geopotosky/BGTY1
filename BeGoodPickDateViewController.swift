//
//  BeGoodPickDateViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit

class BeGoodPickDateViewController: UIViewController {
    
    //-Class outlets
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var pickDateButton: UIButton!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    //-Global objects, properties & variables
    var timeAtPress = Date()
    var currentEventDate: Date!
    var eventText: String!
    
    //-Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag2: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Set Navbar Title
        self.navigationItem.title = "Date Picker"
        
        //-Preset the event date is editing an existing event
        //-Otherwise set the current date
        if editEventFlag2 == true {
            
            let dateFormatter = DateFormatter()
            
            //-Set the selected event date
            myDatePicker.date = currentEventDate
            myDatePicker.minimumDate = Date()

            let timeZone = TimeZone(identifier: "Local")
            dateFormatter.timeZone = timeZone
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            let strDate = dateFormatter.string(from: myDatePicker.date)
            self.eventDateLabel.text = strDate
        }
        else {
            let dateFormatter = DateFormatter()
            
            let date = Date()
            let timeZone = TimeZone(identifier: "Local")
            dateFormatter.timeZone = timeZone
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            let localDate = dateFormatter.string(from: date)
            self.eventDateLabel.text = localDate
        }
        
        
    }
    
    //-Date Picker function
    @IBAction func datePickerAction(_ sender: AnyObject) {
        
        let dateFormatter = DateFormatter()
        myDatePicker.minimumDate = Date()
        
        let timeZone = TimeZone(identifier: "Local")
        dateFormatter.timeZone = timeZone
        //-To prevent displaying either date or time, set the desired style to NoStyle.
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        
        let strDate = dateFormatter.string(from: myDatePicker.date)
        self.eventDateLabel.text = strDate
        self.currentEventDate = myDatePicker.date
        
    }
    
    
    //-Choose the popViewController level (1 or 2) based on whether the user is adding a new event or editing an
    //-existing event
    @IBAction func pickEventDate(_ sender: UIButton) {
        
        if editEventFlag2 == true {
            let controller = self.navigationController!.viewControllers[2] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.currentEventDate = myDatePicker.date
            self.navigationController!.popViewController(animated: true)
            
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.currentEventDate = myDatePicker.date
            self.navigationController!.popViewController(animated: true)
        }
    }
    
}




//
//  BeGoodFlickrViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit

class BeGoodFlickrViewController: UIViewController, UISearchBarDelegate {
    
    //-View Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var flickrActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flickrActivityFrame: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tempImage: UIImageView!
    
    //-Global objects, properties & variables
    var events: [Events]!
    var editEventFlag2: Bool!
    var searchFlag: Bool!
    var flickrImageURL: String!
    var eventIndexPath2: IndexPath!
    var eventImage2: Data!
    var currentImage: UIImage!
    var tapRecognizer: UITapGestureRecognizer? = nil

    
    //-Set the textfield delegates
    let flickrTextDelegate = FlickrTextDelegate()
    
    //-Get the app delegate (used for Flickr API)
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //-Alert variable
    var alertMessage: String!
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Set Navbar Title
        self.navigationItem.title = "Flicker Picker"
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(BeGoodFlickrViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
        searchFlag = false
        pickImageButton.isHidden = true
        flickrActivityIndicator.isHidden = true
        flickrActivityFrame.isHidden = true
        
        searchBar.delegate = self
        
    }
    
    
    //-Perform when view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        //-Display the current or default event image
        if editEventFlag2 == false {
            self.tempImage.isHidden = false
        } else {
            self.tempImage.isHidden = true
            self.photoImageView.image = currentImage
        }
    }
    
    
    //-Perform when view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()

    }

    
    
    //-Call the Flicker Search API with Search Bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchFlag = true
        pickImageButton.isHidden = true
        self.tempImage.isHidden = true
        
        self.flickrActivityFrame.layer.cornerRadius = 47
        self.flickrActivityFrame.backgroundColor = UIColor.white
        self.flickrActivityFrame.isHidden = false
        self.flickrActivityIndicator.isHidden = false
        self.flickrActivityIndicator.startAnimating()
        
        
        //-Set the Flickr Text Phrase for API search
        appDelegate.phraseText = self.searchBar.text
        
        //-Added from student request -- hides keyboard after searching
        self.dismissAnyVisibleKeyboards()
        
        //-Verify Phrase Textfield in NOT Empty
        
        print(self.searchBar.text)
        
        if self.searchBar.text!.isEmpty {
            
            self.flickrActivityIndicator.isHidden = true
            self.flickrActivityIndicator.stopAnimating()
            //-If Phrase is empty, display Empty message
            self.alertMessage = "Search Phrase is Missing"
            self.errorAlertMessage()
            
        } else {
            
            //-Call the Get Flickr Images function
            BGClient.sharedInstance().getFlickrData(self) { (success, pictureURL, errorString) in
                
                if success {
                    
                    self.flickrImageURL = pictureURL
                    let imageURL = URL(string: pictureURL!)
                    
                    //-If an image exists at the url, set the image and title
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        self.eventImage2 = imageData
                        
                        DispatchQueue.main.async(execute: {
                            self.photoImageView.image = UIImage(data: imageData)
                            self.tempImage.isHidden = true
                            self.pickImageButton.isHidden = false
                            self.flickrActivityIndicator.isHidden = true
                            self.flickrActivityFrame.isHidden = true
                            self.flickrActivityIndicator.stopAnimating()
                        })
                        
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.tempImage.isHidden = false
                        })
                    }
                    
                } else {
                    //-Call Alert message
                    self.alertMessage = "\(errorString!)"
                    self.errorAlertMessage()
                } //-End success
                
            } //-End VTClient method
            
        }
        
    }


    //-Pick the selected image button
    @IBAction func pickFlickrImage(_ sender: UIButton) {
        
        //-If edit event flag is set to true, then prep for return to Add VC for existing event
        if editEventFlag2 == true {
            let controller = self.navigationController!.viewControllers[2] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            controller.imageFlag = 3

            self.navigationController!.popViewController(animated: true)
            
        //-If edit event flag is set to false, then prep for return to Add VC for new event
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            controller.imageFlag = 3

            self.navigationController!.popViewController(animated: true)
        }
        
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
    
    
    //-Alert Message function
    func errorAlertMessage(){
        DispatchQueue.main.async {
            let actionSheetController: UIAlertController = UIAlertController(title: "Alert!", message: "\(self.alertMessage!)", preferredStyle: .alert)
            
            self.flickrActivityIndicator.isHidden = true
            self.flickrActivityIndicator.stopAnimating()
            self.flickrActivityFrame.isHidden = true
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blue
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            //alertContentView.backgroundColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
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

//-This extension was added as a fix based on comments
extension BeGoodFlickrViewController {
    func dismissAnyVisibleKeyboards() {
        if searchBar.isFirstResponder {
            self.view.endEditing(true)
        }
    }
}


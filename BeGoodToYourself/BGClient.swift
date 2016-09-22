//
//  BGClient.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//


import Foundation
import UIKit
import CoreData


class BGClient : NSObject {
    
    //-Shared session
    var session: URLSession
    
    //-Get the app delegate
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //-Objects
    var events: Events!
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Get Flickr Pictures Loop
    func getFlickrData(_ hostViewController: UIViewController, completionHandler: @escaping (_ success: Bool, _ pictureURL: String?, _ errorString: String?) -> Void) {
        
        //-Assign Search Phrase shared value
        let searchPhrase = appDelegate.phraseText
        
        let methodArguments = [
            MethodArguments.method: Constants.METHOD_NAME,
            MethodArguments.api_key: Constants.API_KEY,
            MethodArguments.text: searchPhrase,
            MethodArguments.safe_search: Constants.SAFE_SEARCH,
            MethodArguments.extras: Constants.EXTRAS,
            MethodArguments.format: Constants.DATA_FORMAT,
            MethodArguments.nojsoncallback: Constants.NO_JSON_CALLBACK
        ]
        
        //-Call the Flickr API methods and pass back to Flickr View Controller
        self.getImageFromFlickrBySearch(methodArguments as [String : AnyObject]) { (success, pageNumber, errorString) in
            
            if success {
                self.getImageFromFlickrBySearchWithPage(methodArguments as [String : AnyObject], pageNumber: pageNumber) { (success, pictureURL,errorString) in
                    if success {
                        completionHandler(true, pictureURL, errorString)
                    } else {
                        completionHandler(success, nil, errorString)
                    }
                }
            } else {
                completionHandler(success, nil, errorString)
            }
        }
    }
    
    
    //-Flickr API function
    //-Make first request to get a random page, then makes a request to get an image with the random page
    func getImageFromFlickrBySearch(_ methodArguments: [String : AnyObject], completionHandler: @escaping (_ success: Bool, _ pageNumber: Int, _ errorString: String?) -> Void) {
        
        //-Get the Shared NSURLSession to facilitate Network Activity
        let session = URLSession.shared
        //-Create the NSURLRequest using properly escaped URL
        let urlString = Constants.BASE_URL + escapedParameters(methodArguments)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        //-Create NSURLSessionDataTask and completion handler
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            if downloadError != nil {
                completionHandler(false, 0, "Could not complete the request. Try Again.")
            } else {
                
                let parsedResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary
                
                //-Get the photos dictionary
                if let photosDictionary = parsedResult.value(forKey: "photos") as? [String:AnyObject] {
                    
                    //-Determine the total number of photos
                    if let totalPages = photosDictionary["pages"] as? Int {
                        
                        //-Flickr API - will only return up the 4000 images (100 per page * 40 page max)
                        let pageLimit = min(totalPages, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        completionHandler(true, randomPage, nil)
                        
                    } else {
                        completionHandler(false, 0, "No Image Found. Try Again.")
                    }
                } else {
                    completionHandler(false, 0, "No Image Found. Try Again.")
                }
            }
        }) 
        //-Resume (execute) the task
        task.resume()
    }
    
    
    func getImageFromFlickrBySearchWithPage(_ methodArguments: [String : AnyObject], pageNumber: Int, completionHandler: @escaping (_ success: Bool, _ pictureURL: String?, _ errorString: String?) -> Void) {
        
        //-Add the page to the method's arguments
        var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber as AnyObject?
        
        //-Get the Shared NSURLSession to facilitate Network Activity
        let session = URLSession.shared
        
        //-Create the NSURLRequest using properly escaped URL
        let urlString = Constants.BASE_URL + escapedParameters(withPageDictionary)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        //-Create NSURLSessionDataTask and completion handler
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            if downloadError != nil {
                completionHandler(false, nil, "Could not complete the request. Try Again")
            } else {
                let parsedResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary
                
                //-Get the photos dictionary
                if let photosDictionary = parsedResult.value(forKey: "photos") as? [String:AnyObject] {
                    
                    //-Determine the total number of photos
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    print(totalPhotosVal)
                    
                    //-If photos are returned, let's grab one!
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            
                            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                            
                            print(randomPhotoIndex)
                            print("")
                            
                            //-Watch for an empty random photo index
                            if randomPhotoIndex == 0 {
                                completionHandler(false, nil, "No Image Found. Try Again.")
                            }
                            else {
                            
                                let photoDictionary = photosArray[randomPhotoIndex] as [String:AnyObject]
                            
                                //-Get the image url
                                let imageUrlString = photoDictionary["url_m"] as? String
                                let imageURL = URL(string: imageUrlString!)
                                //let urlRequest = URLRequest(url: imageURL!)
                                //let mainQueue = OperationQueue()
                                
                                /* If an image exists at the url, set the image and title */
                                if NSData(contentsOf: imageURL!) != nil {
                                    DispatchQueue.main.async {
                                        completionHandler(true, imageUrlString, nil)
                                        }
                                        //completionHandler(true, imageUrlString, nil)
                                }else {
                                        completionHandler(false, nil, "No Image Found. Try Again.")
                                    }

                                
                                
                                //NSURLConnection.sendAsynchronousRequest(urlRequest, queue: mainQueue, completionHandler://{(response: URLResponse?, data: Data?, error: NSError?) -> Void in
                                    //if data!.count > 0 && error == nil {

                                        //completionHandler(true, imageUrlString, nil)
                                    //}
                                    //else {
                                        //completionHandler(false, nil, "No Image Found. Try Again.")
                                    //}
                                //} as! (URLResponse?, Data?, Error?) -> Void ) //-End NSURLConnection routine

                            } //-End Fix flickr Index Out of Range Error
                            
                        } else {
                            completionHandler(false, nil, "No Image Found. Try Again.")
                        }
                    } else {
                        completionHandler(false, nil, "No Image Found. Try Again.")
                    }
                } else {
                    completionHandler(false, nil, "No Image Found. Try Again.")
                }
            }
        }) 
        
        task.resume()
    }
    
    
    //-Helper function: Given a dictionary of parameters, convert to a string for a url
    func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            //-Make sure that it is a string value
            let stringValue = "\(value)"
            
            //-Escape it
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            //-Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
        
    
    //-Shared Instance
    
    class func sharedInstance() -> BGClient {
        
        struct Singleton {
            static var sharedInstance = BGClient()
        }
        
        return Singleton.sharedInstance
    }
    
}

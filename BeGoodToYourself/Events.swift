//
//  Events.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit
import CoreData

@objc(Events)


class Events : NSManagedObject {
    
    @NSManaged var eventDate: Date?
    @NSManaged var textEvent: String?
    @NSManaged var eventImage: Data?
    @NSManaged var textCalendarID: String?
    @NSManaged var todoList: [TodoList]
    @NSManaged var budget: [Budget]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(eventDate: Date?, textEvent: String?, eventImage: Data?, textCalendarID: String?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Events", in: context)!
        super.init(entity: entity,insertInto: context)
        
        self.eventDate = eventDate
        self.textEvent = textEvent
        self.eventImage = eventImage
        self.textCalendarID = textCalendarID
        
    }
    
    var isOverdue: Bool {
        return (Date().compare(self.eventDate!) == ComparisonResult.orderedDescending) // deadline is earlier than current date
    }
}

//
//  Budget.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit
import CoreData

@objc(Budget)


class Budget : NSManagedObject {
    
    @NSManaged var itemBudgetText: String?
    @NSManaged var priceBudgetText: String?
    @NSManaged var events: Events?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(itemBudgetText: String?, priceBudgetText: String?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Budget", in: context)!
        super.init(entity: entity,insertInto: context)
        
        self.itemBudgetText = itemBudgetText
        self.priceBudgetText = priceBudgetText
        
    }
    
}

//
//  DashboardEvent.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 10/26/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation
import Parse

class DashboardEvent : PFObject {
    
    // As of now we are taking some dummy event attributes, later we will be polishing all the attributes and relations.
    @NSManaged var name:String?
    @NSManaged var time:String?
    @NSManaged var location:String?
    @NSManaged var user:PFUser
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: "DashboardEvent")
        
        query.includeKey("user")
        
        query.orderByAscending("createdAt")
        
        return query
    }
    
    init(name:String?, time:String?, location:String?, user:PFUser) {
        super.init()
        self.name = name
        self.time = time
        self.location = location
        self.user = user
    }
    
    override init() {
        super.init()
    }
}

extension DashboardEvent : PFSubclassing {
    
    class func parseClassName() -> String {
        return "DashboardEvent"
    }
    
//    override class func initialize() {
//        var onceToken: dispatch_once_t = 0
//        dispatch_once(&onceToken) {
//            self.registerSubclass()
//        }
//    }
}
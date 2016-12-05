//
//  UserEvent.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/8/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation
import Parse
import EventKit

class UserEvent : PFObject {
    
    // Some of the essential user event attributes. We will be adding some extra properties in the future.
    @NSManaged var name:String
    @NSManaged var time:NSDate
    @NSManaged var reminderOn:Bool
    @NSManaged var isPublic:Bool
    @NSManaged var isShared:Bool
    @NSManaged var location:String?
    @NSManaged var notes:String?
    @NSManaged var user:PFUser
    @NSManaged var sharedToUsers:[PFUser]
    @NSManaged var calenderItemIdentifier:String
    @NSManaged var completed:Bool
    @NSManaged var completionDate:NSDate?
    
    
    // Funciton that returns a query on the PFObject(in this particular case the PFObject is UserEvent)
    override class func query() -> PFQuery? {
        let query = PFQuery(className: UserEvent.parseClassName())
        
        query.includeKey("user")
        
        query.orderByDescending("createdAt")
        
        return query
    }
    
    // A static/class funciton to get the query that returns all the public events.
    class func queryForPublicEvents() -> PFQuery? {
        
        let query = PFQuery(className: UserEvent.parseClassName())
        query.whereKey("isPublic", equalTo: true)
        
        query.includeKey("user")
        
        query.orderByAscending("createdAt")
        
        return query
    }
    
    class func queryForUpcomingEvents() -> PFQuery? {
        let now:NSDate = NSDate()
        
        let query = PFQuery(className: UserEvent.parseClassName())
        query.whereKey("time", lessThanOrEqualTo: now)
        
        query.includeKey("user")
        query.orderByDescending("time")
        
        return query
    }
    
    class func queryForDashboardEvents() -> PFQuery? {
        let publicEvents = PFQuery(className:UserEvent.parseClassName())
        publicEvents.whereKey("isPublic", equalTo:true)
        
        let sharedEvents = PFQuery(className:UserEvent.parseClassName())
        sharedEvents.whereKey("sharedToUsers", equalTo:PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([publicEvents, sharedEvents])
        
        query.includeKey("user")
        query.orderByDescending("time")
        
        return query
    }
    
    func getSharedContacts() -> [PFUser]? {
        return self.sharedToUsers
    }
    
    // Initializer for UserEvent Class
    init(name:String, reminderOn:Bool, time:NSDate, location:String?, user:PFUser, notes:String?) {
        super.init()
        self.name = name
        self.location = location
        self.user = user
        self.reminderOn = reminderOn
        self.time = time
        self.notes = notes
        self.sharedToUsers = []
        self.isPublic = false
        self.isShared = false
        self.completed = false
    }
    
    override init() {
        super.init()
    }
}

// Parse subclassing so that we can fetch data from backend.
extension UserEvent : PFSubclassing {
    
    class func parseClassName() -> String {
        return "UserEvent"
    }
    
    //    override class func initialize() {
    //        var onceToken: dispatch_once_t = 0
    //        dispatch_once(&onceToken) {
    //            self.registerSubclass()
    //        }
    //    }
}
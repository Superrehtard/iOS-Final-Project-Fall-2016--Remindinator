//
//  UserEvent.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/8/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation
import Parse

class UserEvent : PFObject {
    
    // As of now we are taking some dummy event attributes, later we will be polishing all the attributes and relations.
    @NSManaged var name:String?
    @NSManaged var time:NSDate!
    @NSManaged var isPublic:Bool
    @NSManaged var isShared:Bool
    @NSManaged var location:String?
    @NSManaged var user:PFUser
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: UserEvent.parseClassName())
        
        query.includeKey("user")
        
        query.orderByAscending("createdAt")
        
        return query
    }
    
    init(name:String?, time:NSDate, location:String?, user:PFUser) {
        super.init()
        self.name = name
        self.time = time
        self.location = location
        self.user = user
        self.isPublic = false
        self.isShared = false
    }
    
    override init() {
        super.init()
    }
}

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
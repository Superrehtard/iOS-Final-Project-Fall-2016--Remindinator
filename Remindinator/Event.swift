//
//  Events.swift
//  Remindinator
//
//  Created by Peram,Vinod Kumar Reddy on 10/23/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation
class Event {
    var eventName:String
    var dueDate:NSDate
    var description:String
    var location:String
    var tasks:[Task]
    
    init(eventName:String, dueDate:NSDate, description:String, location: String, tasks:[Task]){
        self.eventName = eventName
        self.dueDate = dueDate
        self.description = description
        self.location = location
        self.tasks = tasks
    }
}
//
//  Tasks.swift
//  Remindinator
//
//  Created by Peram,Vinod Kumar Reddy on 10/23/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation
class Tasks{
    var isCompleted:Bool
    var dateFrom:NSDate
    var dateTo:NSDate
    var taskID:String
    var taskName:String
    init(isCompleted:Bool, dateFrom:NSDate, dateTo:NSDate, taskID:String,taskName:String){
        self.isCompleted = isCompleted
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.taskID = taskID
        self.taskName = taskName
    }
}

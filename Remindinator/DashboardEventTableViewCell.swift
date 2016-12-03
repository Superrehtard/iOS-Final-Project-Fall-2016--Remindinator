//
//  DashboardEventTableViewCell.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse

// A custom Parse TableViewCell that has its own labels and image views.

class DashboardEventTableViewCell : PFTableViewCell {
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventReminderTime : UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var addOrEditButton: UIButton!
    
    var user:PFUser!
    var objectId:String!
}

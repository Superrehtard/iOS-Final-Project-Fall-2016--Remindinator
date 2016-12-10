//
//  DashboardTableViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import EventKit

class DashboardTableViewController: PFQueryTableViewController {
    
    var eventsPopulated:[UserEvent] = []
    var eventStore:EKEventStore!
    var sharedToCurrentUser:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.eventStore = appDelegate.eventStore
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadEvents()
        loadObjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function is called everytime the view appears and it loads all the userevents into the eventsPopulated array.
    func loadEvents() {
        self.eventsPopulated.removeAll()
        
        let query = UserEvent.query()
        
        query!.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    if objects?.count > 0 {
                        for object in objects! {
                            self.eventsPopulated.append(object as! UserEvent)
                        }
                    }
                    print("Successfully fetched all userEvents")
                }
            } else {
                if let error = error {
                    print("Something has gone terribly wrong! \(error.localizedDescription)")
                }
            }
        }
    }
    
    //Function that return the event for which the user has clicked on the edit button.
    func eventSelectedToEdit(cell:UITableViewCell) -> UserEvent {
        
        var eventSelected:UserEvent!
        
        for event in self.eventsPopulated {
            if ((event.objectId?.compare((cell as! DashboardEventTableViewCell).objectId)) == .OrderedSame) {
                eventSelected = event
            }
        }
        
        return eventSelected
    }
    
    //Here all the segues are handled based on their identifiers.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddEvent" {
            let addEventVC = segue.destinationViewController as! AddEventTableViewController
            
            addEventVC.delegate = self
        }
        
        if segue.identifier == "EditEvent" {
            let editEventVC = segue.destinationViewController as! AddEventTableViewController
            
            editEventVC.delegate = self
            
            let touchPoint = (sender as! UIButton).convertPoint(CGPointZero, toView: self.tableView)
            
            editEventVC.eventToEdit = eventSelectedToEdit(tableView.cellForRowAtIndexPath(self.tableView.indexPathForRowAtPoint(touchPoint)!)!)
        }
        
        if segue.identifier == "MakeMyEvent" {
            let addEventVC = segue.destinationViewController as! AddEventTableViewController
            
            addEventVC.delegate = self
            
            let touchPoint = (sender as! UIButton).convertPoint(CGPointZero, toView: self.tableView)
            
            addEventVC.existingEventToAdd = eventSelectedToEdit(tableView.cellForRowAtIndexPath(self.tableView.indexPathForRowAtPoint(touchPoint)!)!)
        }
    }
}

extension DashboardTableViewController {
    
    override func queryForTable() -> PFQuery {
        let query = UserEvent.queryForDashboardEvents()
        return query!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell:DashboardEventTableViewCell
        
        let event = object as! UserEvent
        self.sharedToCurrentUser = false
        
        event.getSharedContacts()?.forEach({ (user) in
            if PFUser.currentUser()!.objectId == user.objectId {
                self.sharedToCurrentUser = true
                return
            }
        })
        
        if event.user.objectId?.compare((PFUser.currentUser()?.objectId)!) == .OrderedSame || self.sharedToCurrentUser {
            cell = tableView.dequeueReusableCellWithIdentifier("UserEventCell", forIndexPath: indexPath) as! DashboardEventTableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("PublicEventCell", forIndexPath: indexPath) as! DashboardEventTableViewCell
        }
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage.clipsToBounds = true
        
        cell.userImage.layer.borderWidth = 3
        cell.userImage.layer.borderColor = UIColor.darkTextColor().CGColor
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        if let userImageFile = event.user["image"] as? PFFile {
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.userImage.image = UIImage(data:imageData)
                    }
                } else {
                    if let error = error {
                        print("Something has gone wrong when getting the userImage from the background: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            let image = UIImage(named: "DefaultImage")
            let imageData = UIImagePNGRepresentation(image!)
            let imageFile = PFFile(name: event.user.username, data: imageData!)
            
            event.user["image"] = imageFile
            
            event.user.saveInBackground()
            cell.userImage.image = image
        }
        
        cell.eventName.text = event.eventName
        cell.objectId = event.objectId
        cell.eventReminderTime.text = dateFormatter.stringFromDate(event.eventDueDate)
        cell.user = event.user
        cell.addOrEditButton.tag = indexPath.row
        
        if event.eventDueDate.compare(NSDate()) == .OrderedDescending {
            if event.completed {
                cell.eventReminderTime.textColor = UIColor.greenColor().colorWithAlphaComponent(0.75)
            }
        } else {
            cell.eventReminderTime.textColor = UIColor.redColor()
        }
        
        return cell
    }
    
    // This functions tells which all table view cells can be deleted. Only event that are his own can be edited by the user.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? DashboardEventTableViewCell {
            if cell.user.objectId?.compare((PFUser.currentUser()?.objectId)!) == .OrderedSame {
                return true
            }
        }
        
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let event = self.objectAtIndexPath(indexPath) as! UserEvent
        
        if event.user.objectId?.compare((PFUser.currentUser()?.objectId)!) == .OrderedSame {
            let alertController = UIAlertController(title: event.eventName, message: .None, preferredStyle: .ActionSheet)
            
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                
                if event.completed == true {
                    let alertMessage = UIAlertController(title: "Warning", message: "Event already completed.", preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                } else {
                    event.completed = true
                    
                    event.saveInBackgroundWithBlock{ succeeded, error in
                        if succeeded {
                            // when the event is successfully saved.
                            if event.calenderItemIdentifier != "" {
                                let reminderToEdit = self.eventStore.calendarItemWithIdentifier(event.calenderItemIdentifier) as! EKReminder
                                
                                reminderToEdit.completed = true
                                
                                reminderToEdit.alarms?.removeAll()
                                reminderToEdit.calendar = self.eventStore.defaultCalendarForNewReminders()
                                do {
                                    try self.eventStore.saveReminder(reminderToEdit, commit: true)
                                    let alert:UIAlertController = UIAlertController(title: "Success", message: "Event Updated succesfully!", preferredStyle: .Alert)
                                    let defaultAction:UIAlertAction =  UIAlertAction(title: "OK", style: .Default, handler: nil)
                                    alert.addAction(defaultAction)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }catch{
                                    self.displayAlertWithTitle("Error!", message: "Error updating reminder :\(error)")
                                    print("Error creating and saving new reminder : \(error)")
                                }
                            } else {
                                let alertMessage = UIAlertController(title: "Success", message: "Event successfully marked as complete.", preferredStyle: .Alert)
                                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                self.presentViewController(alertMessage, animated: true, completion: nil)
                            }
                        } else {
                            // when the event is not stored successfully.
                            if (error?.userInfo["error"] as? String) != nil {
                                let alertMessage = UIAlertController(title: "Failed!", message: error?.localizedDescription, preferredStyle: .Alert)
                                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                self.presentViewController(alertMessage, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            let callAction = UIAlertAction(title: "Mark as Completed", style: .Default, handler: callActionHandler)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(callAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //Function that implements the deleting functionality to the tableviewcells.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DashboardEventTableViewCell
        
        let query = PFQuery(className: UserEvent.parseClassName())
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if objects?.count > 0 {
                    for event in objects! {
                        if (((event as! UserEvent).objectId?.compare(cell.objectId!)) == .OrderedSame) {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                if (event as! UserEvent).calenderItemIdentifier != "" {
                                    
                                    let reminderToDelete = self.eventStore.calendarItemWithIdentifier((event as! UserEvent).calenderItemIdentifier) as! EKReminder
                                    
                                    do{
                                        try self.eventStore.removeReminder(reminderToDelete, commit: true)
                                        print("Reminder successfully deleted!")
                                    }catch{
                                        print("An error occurred while removing the reminder from the Calendar database: \(error)")
                                    }
                                }
                                
                                event.deleteInBackground()
                                print("Successfully fetched UserEvent and Deleted the Same!")
                            }
                        }
                    }
                }
            } else {
                if let error = error {
                    print("Something has gone terribly wrong! \(error.localizedDescription)")
                }
            }
        }
        
        self.loadObjects()
        tableView.reloadData()
    }
}

extension DashboardTableViewController : AddEventTableViewControllerDelegate {
    func addEventTableViewControllerDidCancel(controller: AddEventTableViewController) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func addEventTableViewController(controller: AddEventTableViewController, didFinishAddingEvent event: UserEvent) {
        event.saveInBackgroundWithBlock{ succeeded, error in
            if succeeded {
                // when the event is successfully saved.
                print("Successfully saved Event!")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                // when the event is not stored successfully.
                if let errorMessage = error?.userInfo["error"] as? String {
                    print("\(error?.localizedDescription) : \(errorMessage)")
                }
            }
        }
    }
    
    func addEventTableViewController(controller: AddEventTableViewController, didFinishEditingEvent event: UserEvent) {
        
        let query = PFQuery(className: UserEvent.parseClassName())
        
        query.getObjectInBackgroundWithId(event.objectId!) {
            (userEvent: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    userEvent!["eventName"] = event.eventName
                    userEvent!["eventLocation"] = event.eventLocation
                    userEvent!["eventNotes"] = event.eventNotes
                    userEvent!["user"] = event.user
                    userEvent!["isReminderOn"] = event.isReminderOn
                    userEvent!["eventDueDate"] = event.eventDueDate
                    userEvent!["sharedToUsers"] = event.sharedToUsers
                    userEvent!["isPublic"] = event.isPublic
                    userEvent!["isShared"] = event.isShared
                    userEvent!["completed"] = false
                    
                    userEvent?.saveInBackground()
                    
                    if event.calenderItemIdentifier != "" && event.isReminderOn {
                        
                        
                        let reminderToEdit = self.eventStore.calendarItemWithIdentifier(event.calenderItemIdentifier) as! EKReminder
                        
                        reminderToEdit.title = event.eventName
                        reminderToEdit.completed = false
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let dueDateComponents = appDelegate.dateComponentFromNSDate(event.eventDueDate)
                        reminderToEdit.dueDateComponents = dueDateComponents
                        reminderToEdit.alarms?.first?.absoluteDate = NSCalendar.currentCalendar().dateFromComponents(dueDateComponents)
                        reminderToEdit.calendar = self.eventStore.defaultCalendarForNewReminders()
                        do {
                            try self.eventStore.saveReminder(reminderToEdit, commit: true)
                            let alert:UIAlertController = UIAlertController(title: "Success", message: "Event Updated succesfully!", preferredStyle: .Alert)
                            let defaultAction:UIAlertAction =  UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                                
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                            alert.addAction(defaultAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }catch{
                            self.displayAlertWithTitle("Error!", message: "Error updating reminder :\(error)")
                        }
                    } else if event.calenderItemIdentifier != "" && !event.isReminderOn {
                        let reminderToDelete = self.eventStore.calendarItemWithIdentifier(event.calenderItemIdentifier) as! EKReminder
                        
                        
                        do{
                            try self.eventStore.removeReminder(reminderToDelete, commit: true)
                            let alert:UIAlertController = UIAlertController(title: "Success", message: "Event Updated succesfully!", preferredStyle: .Alert)
                            let defaultAction:UIAlertAction =  UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                                
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                            alert.addAction(defaultAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }catch{
                            self.displayAlertWithTitle("Error!", message: "Error updating reminder :\(error)")
                            print("Error deleting reminder : \(error)")
                        }
                        
                    } else if event.calenderItemIdentifier == "" && event.isReminderOn {
                        let reminder = EKReminder(eventStore: self.eventStore)
                        reminder.title = event.eventName
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                        reminder.dueDateComponents = appDelegate.dateComponentFromNSDate(event.eventDueDate)
                        
                        let alarm = EKAlarm(absoluteDate: event.eventDueDate)
                        
                        reminder.addAlarm(alarm)
                        
                        do {
                            try self.eventStore.saveReminder(reminder, commit: true)
                        }catch{
                            print("Error creating and saving new reminder : \(error)")
                        }
                        
                        userEvent!["calenderItemIdentifier"] = reminder.calendarItemIdentifier
                        userEvent?.saveInBackground()
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            } else {
                if let error = error {
                    print("Something has gone terribly wrong! \(error.localizedDescription)")
                }
            }
        }
    }
}

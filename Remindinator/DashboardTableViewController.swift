//
//  DashboardTableViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import EventKit

class DashboardTableViewController: PFQueryTableViewController, AddEventTableViewControllerDelegate {
    
    var eventsPopulated:[UserEvent] = []
    var eventStore:EKEventStore!
    var sharedToCurrentUser:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.eventStore = appDelegate.eventStore
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadEvents()
        loadObjects()
    }
    
    override func queryForTable() -> PFQuery {
        let query = UserEvent.queryForDashboardEvents()
        return query!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        print(PFUser.currentUser()?.username)
        
        if let userImageFile = event.user["image"] as? PFFile {
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.userImage.image = UIImage(data:imageData)
                    }
                    print("Successfully fetched image from the Backend.")
                } else {
                    if let error = error {
                        print("Something has gone wrong when getting the userImage from the background: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            let image = UIImage(named: "Gender Neutral User Filled-100")
            let imageData = UIImagePNGRepresentation(image!)
            let imageFile = PFFile(name: event.user.username, data: imageData!)
            
            event.user["image"] = imageFile
            
            event.user.saveInBackground()
            cell.userImage.image = image
        }
        
        cell.eventName.text = event.name
        cell.objectId = event.objectId
        cell.eventReminderTime.text = dateFormatter.stringFromDate(event.time)
        cell.user = event.user
        
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
                                print((event as! UserEvent).calenderItemIdentifier)
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
                            
//                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
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
    
    //This function is called everytime the view appears and it loads all the userevents into the eventsPopulated array.
    func loadEvents() {
        self.eventsPopulated.removeAll()
        
        let query = PFQuery(className: UserEvent.parseClassName())
        
        query.findObjectsInBackgroundWithBlock {
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
                    userEvent!["name"] = event.name
                    userEvent!["location"] = event.location
                    userEvent!["user"] = event.user
                    userEvent!["reminderOn"] = event.reminderOn
                    userEvent!["time"] = event.time
                    userEvent!["sharedToUsers"] = event.sharedToUsers
                    userEvent!["isPublic"] = event.isPublic
                    userEvent!["isShared"] = event.isShared
                    
                    userEvent?.saveInBackground()
                    
                    print("Successfully updated the userevent!!")
                    
                    if event.calenderItemIdentifier != "" {
                        
                        
                        let reminderToEdit = self.eventStore.calendarItemWithIdentifier(event.calenderItemIdentifier) as! EKReminder
                        
                        reminderToEdit.title = event.name
                        reminderToEdit.completed = false
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let dueDateComponents = appDelegate.dateComponentFromNSDate(event.time)
                        reminderToEdit.dueDateComponents = dueDateComponents
                        reminderToEdit.alarms?.first?.absoluteDate = NSCalendar.currentCalendar().dateFromComponents(dueDateComponents)
                        reminderToEdit.calendar = self.eventStore.defaultCalendarForNewReminders()
                        do {
                            try self.eventStore.saveReminder(reminderToEdit, commit: true)
                            self.navigationController?.popViewControllerAnimated(true)
                        }catch{
                            print("Error creating and saving new reminder : \(error)")
                        }
                        
                    }
                    
//                    self.navigationController?.popViewControllerAnimated(true)
                }
            } else {
                if let error = error {
                    print("Something has gone terribly wrong! \(error.localizedDescription)")
                }
            }
        }
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
            
            if let indexPath = self.tableView.indexPathForCell(sender as! DashboardEventTableViewCell) {
                editEventVC.eventToEdit = eventSelectedToEdit(tableView.cellForRowAtIndexPath(indexPath)!)
            }
        }
    }
    
}

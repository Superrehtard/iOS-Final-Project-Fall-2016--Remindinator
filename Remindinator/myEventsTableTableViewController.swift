//
//  myEventsTableTableViewController.swift
//  Remindinator
//
//  Created by Peram,Vinod Kumar Reddy on 10/23/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import EventKit

class myEventsTableTableViewController: PFQueryTableViewController, AddEventTableViewControllerDelegate {

    var eventsPopulated:[UserEvent] = []
    var eventStore:EKEventStore!
    weak var delegate:AddEventTableViewControllerDelegate?
    
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
        loadObjects()
        loadEvents()
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: UserEvent.parseClassName())
        query.includeKey("user")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.orderByDescending("time")
        return query
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserEventCell", forIndexPath: indexPath) as! DashboardEventTableViewCell
        
        let event = object as! UserEvent
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
                    print(self.eventsPopulated.count)
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
        print("event selected")
        for event in self.eventsPopulated {
             print("event populated")
            if ((event.objectId?.compare((cell as! DashboardEventTableViewCell).objectId)) == .OrderedSame) {
                eventSelected = event
               
            }
        }
        
        return eventSelected
    }

    
    //Function that implements the deleting functionality to the tableviewcells.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DashboardEventTableViewCell
        
        let query = PFQuery(className: UserEvent.parseClassName())
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    if objects?.count > 0 {
                        for object in objects! {
                            if (((object as! UserEvent).objectId?.compare(cell.objectId!)) == .OrderedSame) {
                                object.deleteInBackground()
                            }
                        }
                    }
                    self.loadObjects()
                    tableView.reloadData()
                    print("Successfully fetched Userevent and deleted the same.")
                }
            } else {
                if let error = error {
                    print("Something has gone terribly wrong! \(error.localizedDescription)")
                }
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    func addEventTableViewControllerDidCancel(controller: AddEventTableViewController) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func addEventTableViewController(controller: AddEventTableViewController, didFinishEditingEvent event: UserEvent) {
        
        let query = PFQuery(className: UserEvent.parseClassName())
        
        query.getObjectInBackgroundWithId(event.objectId!) {
            (userEvent: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    userEvent!["name"] = event.name
                    userEvent!["location"] = event.location
                    userEvent!["notes"] = event.notes
                    userEvent!["user"] = event.user
                    userEvent!["reminderOn"] = event.reminderOn
                    userEvent!["time"] = event.time
                    userEvent!["sharedToUsers"] = event.sharedToUsers
                    userEvent!["isPublic"] = event.isPublic
                    userEvent!["isShared"] = event.isShared
                    userEvent!["completed"] = false
                    
                    userEvent?.saveInBackground()
                    
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
                            let alert:UIAlertController = UIAlertController(title: "Success", message: "Event Updated succesfully!", preferredStyle: .Alert)
                            let defaultAction:UIAlertAction =  UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                                
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                            alert.addAction(defaultAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }catch{
                            self.displayAlertWithTitle("Error!", message: "Error updating reminder :\(error)")
                            print("Error creating and saving new reminder : \(error)")
                        }
                    }
                }
            } else {
                if let error = error {
                    print("Something has gone terribly wrong! \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addEventTableViewController(controller: AddEventTableViewController, didFinishAddingEvent event: UserEvent) {
        return
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Edit Event" {
            let editEventVC = segue.destinationViewController as! AddEventTableViewController
            
            editEventVC.delegate = self
            
            //editEventVC.delegate = self
            if let indexPath = self.tableView.indexPathForCell(sender as! DashboardEventTableViewCell) {
                editEventVC.eventToEdit = eventSelectedToEdit(tableView.cellForRowAtIndexPath(indexPath)!)
            }
            
        }

    }
    
    func displayAlertWithTitle(title:String, message:String){
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction:UIAlertAction =  UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

}

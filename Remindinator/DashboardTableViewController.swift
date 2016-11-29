//
//  DashboardTableViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit

class DashboardTableViewController: PFQueryTableViewController, AddEventTableViewControllerDelegate {
    
    var eventsPopulated:[UserEvent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadEvents()
        loadObjects()
        self.tableView.reloadData()
    }
    
    override func queryForTable() -> PFQuery {
        let query = UserEvent.queryForPublicEvents()
        return query!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! DashboardEventTableViewCell
        
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
                    self.navigationController?.popViewControllerAnimated(true)
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

//
//  ContactsTableViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/14/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ContactsTableViewController: PFQueryTableViewController {
    
    var contacts:[PFUser] = []
    var userEvent:UserEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadObjects()
    }
    
    // this query gets the objects neccessary for the tableview.
    override func queryForTable() -> PFQuery {
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
        
        return query!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Contact_Cell", forIndexPath: indexPath) as! ContactTableViewCell
        
        let user = object as! PFUser
        
        cell.contactName.text = user.username
        if !self.contacts.isEmpty {
            for contact in self.contacts {
                if contact.objectId!.compare(user.objectId!) == .OrderedSame {
                    cell.accessoryType = .Checkmark
                    return cell
                }
            }
        }
        
        cell.accessoryType = .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selecetdUser:PFUser? = nil
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell {
            let query = PFUser.query()
            query?.whereKey("username", equalTo: (cell.contactName?.text)!)
            // Need to find out why the below approach is not preferred and why it is crashing the app.
            //            do {
            //                let users = try query?.findObjects()
            //
            //                selecetdUser = users![0] as? PFUser
            //
            //
            //            } catch let error as NSError {
            //                print("Something went wrong \(error.localizedDescription)")
            //            }
            
            
            // Gets all the userEvent object that was selected.
            query!.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if let objects = objects {
                        selecetdUser = objects[0] as? PFUser
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if cell.accessoryType == .None {
                            cell.accessoryType = .Checkmark
                            
                            self.contacts.append(selecetdUser!)
                        } else {
                            for user in self.contacts {
                                if user.username == selecetdUser?.username {
                                    self.contacts.removeAtIndex(self.contacts.indexOf(user)!)
                                }
                            }
                            
                            cell.accessoryType = .None
                        }
                    }
                    // Check to see if the query returned any objects.
                    print("Successfully retrieved: \(objects!.count)")
                } else {
                    // Log details of the failure
                    print("Error: \(error) \(error?.localizedDescription)")
                }
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // cancel adding contacts.
    @IBAction func cancelAddingContacts(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func doneAddingContacts(sender: AnyObject) {
        
    }
    
}

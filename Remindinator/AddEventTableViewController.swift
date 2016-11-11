//
//  AddEventTableViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit

class AddEventTableViewController: UITableViewController {
    
    var datePickerVisible = false
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var isPublicToggleSwitch: UISwitch!
    @IBOutlet weak var isSharedToggleSwitch: UISwitch!
    @IBOutlet weak var reminderToggleSwitch: UISwitch!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var userEventDP: UIDatePicker!
    
    @IBAction func addEvent(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let date = dateFormatter.dateFromString((self.eventDateLabel?.text!)!)
        
        let dashboardEvent = UserEvent(name: eventNameTextField.text, time: date!, location: "Some Location", user: PFUser.currentUser()!)
        dashboardEvent.isPublic = self.isPublicToggleSwitch.on
        dashboardEvent.isShared = self.isSharedToggleSwitch.on
        
        dashboardEvent.saveInBackgroundWithBlock{ succeeded, error in
            if succeeded {
                //3
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                //4
                if let errorMessage = error?.userInfo["error"] as? String {
                    print(errorMessage)
                }
            }
        }
    }
    
    @IBAction func dateValueChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        eventDateLabel.text = dateFormatter.stringFromDate(sender.date)
    }
    
    @IBAction func isSharedValueChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    @IBAction func reminderSwitchValueChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            eventNameTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 1 {
                datePickerVisible = !datePickerVisible
                tableView.reloadData()
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 2 && !isSharedToggleSwitch.on {
                return 0.0
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 1 && !reminderToggleSwitch.on {
                return 0.0
            }
            if indexPath.row == 2 {
                if !reminderToggleSwitch.on || !datePickerVisible {
                    return 0.0
                }
                return 165.0
            }
        }
        
        return 44.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(EventNameTableViewCell.self, forCellReuseIdentifier: "eventName_Cell")
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.userEventDP.minimumDate = NSDate()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Table view data source
     
     override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 0
     }
     
     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // #warning Incomplete implementation, return the number of rows
     return 0
     }
     */
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

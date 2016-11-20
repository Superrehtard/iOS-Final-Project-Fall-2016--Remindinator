//
//  AddEventTableViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse

class AddEventTableViewController: UITableViewController, UITextFieldDelegate {
    
    // Stored properties.
    var datePickerVisible = false
    var sharedContacts:[PFUser] = []
    
    // UserEvent that is to be edited.
    var eventToEdit:UserEvent!
    
    // Outlets.
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var isPublicToggleSwitch: UISwitch!
    @IBOutlet weak var isSharedToggleSwitch: UISwitch!
    @IBOutlet weak var contactsAddedLabel: UILabel!
    @IBOutlet weak var reminderToggleSwitch: UISwitch!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var userEventDP: UIDatePicker!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Function called when user clicks on Add. This functions adds an userEvent in the background.
    @IBAction func addEvent(sender: AnyObject) {
        
        // getting the date set fromt the date picker.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let date = dateFormatter.dateFromString((self.eventDateLabel?.text!)!)
        
        // creating the UserEvent based on the user input.
        let dashboardEvent = UserEvent(name: eventNameTextField.text, time: date!, location: "Some Location", user: PFUser.currentUser()!)
        dashboardEvent.isPublic = self.isPublicToggleSwitch.on
        dashboardEvent.isShared = self.isSharedToggleSwitch.on
        
        // when the share switch is toggled on, the added contacts are stored in the userEvent.
        if self.isSharedToggleSwitch.on {
            dashboardEvent.sharedToUsers = self.sharedContacts
        }
        
        //Save the newly created userEvent.
        // To Do:## Refactor the object name to something meaningful.
        dashboardEvent.saveInBackgroundWithBlock{ succeeded, error in
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
    
    //Whenever the datepicker value is changed, this function is called.
    @IBAction func dateValueChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        eventDateLabel.text = dateFormatter.stringFromDate(sender.date)
    }
    
    // Function called whenever the isShared switch is toggled.
    @IBAction func isSharedValueChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    // function called whenever the reminder switch is toggled.
    @IBAction func reminderSwitchValueChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    // To dynamically produce table cells based on UISwitch controls.
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
    
    // The dynamic cell generation is done by manupulating the heights for the tableview based on the UI switch controls.
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
    
    // Default height for all the tableview cells.
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(EventNameTableViewCell.self, forCellReuseIdentifier: "eventName_Cell")
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.userEventDP.minimumDate = NSDate()
        
        eventNameTextField.becomeFirstResponder()
        
        if let event = eventToEdit {
            self.title = "Edit Event"
            
            self.eventNameTextField.text = event.name
            self.isPublicToggleSwitch.on = event.isPublic
            self.isSharedToggleSwitch.on = event.isShared
            self.reminderToggleSwitch.on = event.time != nil ? true : false
            if event.time != nil {
                self.eventDateLabel.text = String(event.time)
                self.eventDatePicker.date = event.time
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Unwind segue from contactsViewController to Add event page.
    @IBAction func unwindSegueForContacts(segue: UIStoryboardSegue) {
        let contactsTV = segue.sourceViewController as! ContactsTableViewController
        
        self.sharedContacts = contactsTV.contacts
        
        self.contactsAddedLabel.text = "\(self.sharedContacts.count) People Added."
    }
    
    // function is called when user cancels adding a event.
    @IBAction func cancelAddingEvent(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // This funciton enables or disabled eventName textfield based on its contents.
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText:NSString = textField.text!
        
        let newText:NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        doneBarButtonItem.enabled = (newText.length > 0)
        
        return true
    }
    
    //This function controls whether the 'Done' should be enabled or not.
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text?.characters.count > 0 {
            doneBarButtonItem.enabled = true
        } else {
            doneBarButtonItem.enabled = false
        }
    }
    
    //Remove the text field from being the first responder on hitting return.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // This segment persists the contacts added from and to contacts view controller.
        if segue.identifier == "Contacts_Segue" {
            let contactsTV = segue.destinationViewController as! ContactsTableViewController
            
            contactsTV.contacts = self.sharedContacts
        }
    }
    
    
    
}

//
//  AddEventTableViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse
import EventKit

protocol AddEventTableViewControllerDelegate : class {
    func addEventTableViewControllerDidCancel(controller: AddEventTableViewController)
    func addEventTableViewController(controller: AddEventTableViewController, didFinishAddingEvent event: UserEvent)
    func addEventTableViewController(controller: AddEventTableViewController, didFinishEditingEvent event: UserEvent)
}

class AddEventTableViewController: UITableViewController, UITextFieldDelegate {
    
    // Stored properties.
    var datePickerVisible = false
    var dueDate = NSDate()
    var sharedContacts:[PFUser] = []
    weak var delegate:AddEventTableViewControllerDelegate?
    
    // UserEvent that is to be edited.
    var eventToEdit:UserEvent!
    
    // Event Store
    var eventStore:EKEventStore!
    
    // Outlets.
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var isPublicToggleSwitch: UISwitch!
    @IBOutlet weak var isSharedToggleSwitch: UISwitch!
    @IBOutlet weak var contactsAddedLabel: UILabel!
    @IBOutlet weak var reminderToggleSwitch: UISwitch!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var eventDatePickerCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        eventStore = appDelegate.eventStore
        
        tableView.registerClass(EventNameTableViewCell.self, forCellReuseIdentifier: "eventName_Cell")
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.eventDatePicker.minimumDate = NSDate()
        
        eventNameTextField.becomeFirstResponder()
        
        if let event = eventToEdit {
            self.title = "Edit Event"
            
            self.eventNameTextField.text = event.name
            self.isPublicToggleSwitch.on = event.isPublic
            self.isSharedToggleSwitch.on = event.isShared
            self.reminderToggleSwitch.on = event.reminderOn
            self.dueDate = event.time
            self.updateEventDateLabel()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Function called when user clicks on Add. This functions adds an userEvent in the background.
    @IBAction func done(sender: AnyObject) {
        
        if let event = eventToEdit {
            getUpdatedEvent(event)
            
            self.delegate?.addEventTableViewController(self, didFinishEditingEvent: event)
        } else {
            // getting the date set from the date picker.
            if self.reminderToggleSwitch.on {
                getEventDate()
            }
            
            // creating the UserEvent based on the user input.
            let event = UserEvent(name: eventNameTextField.text!,reminderOn:self.reminderToggleSwitch.on, time: self.dueDate, location: "Some Location", user: PFUser.currentUser()!)
            event.isPublic = self.isPublicToggleSwitch.on
            event.isShared = self.isSharedToggleSwitch.on
            
            // when the share switch is toggled on, the added contacts are stored in the userEvent.
            if self.isSharedToggleSwitch.on {
                event.sharedToUsers = self.sharedContacts
            }
            
            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = eventNameTextField.text!
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
            reminder.dueDateComponents = appDelegate.dateComponentFromNSDate(self.dueDate)
            
            let alarm = EKAlarm(absoluteDate: self.dueDate)
            
            reminder.addAlarm(alarm)
            
            // 2
            do {
                try self.eventStore.saveReminder(reminder, commit: true)
                dismissViewControllerAnimated(true, completion: nil)
            }catch{
                print("Error creating and saving new reminder : \(error)")
            }
            
            event.calenderItemIdentifier = reminder.calendarItemIdentifier
            
            print(event.calenderItemIdentifier)
            
            // Save the newly created userEvent.
            self.delegate?.addEventTableViewController(self, didFinishAddingEvent: event)
        }
    }
    
    //Function to assign the values on the form to the passed in event.
    func getUpdatedEvent(event: UserEvent) {
        getEventDate()
        
        event.name = eventNameTextField.text!
        event.reminderOn = self.reminderToggleSwitch.on
        event.time = self.dueDate
        event.isPublic = self.isPublicToggleSwitch.on
        event.isShared = self.isSharedToggleSwitch.on
        
        if self.isSharedToggleSwitch.on {
            event.sharedToUsers = self.sharedContacts
        } else {
            event.sharedToUsers = []
        }
    }
    
    //Whenever the datepicker value is changed, this function is called.
    @IBAction func dateValueChanged(sender: UIDatePicker) {
        self.dueDate = sender.date
        self.updateEventDateLabel()
    }
    
    func getEventDate() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        self.dueDate = dateFormatter.dateFromString((self.eventDateLabel?.text!)!)!
    }
    
    func updateEventDateLabel() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        eventDateLabel.text = formatter.stringFromDate(dueDate)
    }
    
    // Function called whenever the isShared switch is toggled.
    @IBAction func isSharedValueChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    // function called whenever the reminder switch is toggled.
    @IBAction func reminderSwitchValueChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    func showDatePicker() {
        self.datePickerVisible = true
        
        let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 2)
        let indexPathForDatePicker = NSIndexPath(forRow: 2, inSection: 2)
        
        if let dateRow = tableView.cellForRowAtIndexPath(indexPathDateRow) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .ShortStyle
            dateRow.detailTextLabel?.text = dateFormatter.stringFromDate(dueDate)
            dateRow.detailTextLabel?.textColor = dateRow.detailTextLabel?.tintColor
        }
        
        tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([indexPathForDatePicker], withRowAnimation: .Fade)
        self.tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
        tableView.endUpdates()
        
        self.eventDatePicker.setDate(dueDate, animated: false)
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            self.datePickerVisible = false
            
            let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 2)
            let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 2)
            
            if let dateRow = tableView.cellForRowAtIndexPath(indexPathDateRow) {
                dateRow.detailTextLabel?.textColor = UIColor(white: 0, alpha: 0.5)
            }
            
            tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
            self.tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 && indexPath.row == 2 {
            return self.eventDatePickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2 && self.datePickerVisible {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    // To dynamically produce table cells based on UISwitch controls.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        eventNameTextField.resignFirstResponder()
        
        if indexPath.section == 2 && indexPath.row == 1 {
            if self.datePickerVisible {
                hideDatePicker()
            } else {
                showDatePicker()
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 2 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        var index = indexPath
        
        if indexPath.section == 2 && indexPath.row == 2 {
            index = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: index)
    }
    
    // The dynamic cell generation is done by manupulating the heights for the tableview based on the UI switch controls.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 2 && !isSharedToggleSwitch.on {
                return 0.0
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            if reminderToggleSwitch.on {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            } else {
                return 0.0
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    // Default height for all the tableview cells.
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
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
        delegate?.addEventTableViewControllerDidCancel(self)
        
//        self.navigationController?.popViewControllerAnimated(true)
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
        self.hideDatePicker()
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

//
//  RegistrationViewController.swift
//  Remindinator
//
//  Created by Peram,Vinod Kumar Reddy on 10/25/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse

class RegistrationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

 
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailOrUserNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var mobileNumberTF: UITextField!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signUpBTN(sender: AnyObject) {
        let userDetails = PFObject(className: "userDetails")
        userDetails["firstName"] = firstNameTF.text!
        userDetails["lastName"] = lastNameTF.text!
        userDetails["emailID"] = emailOrUserNameTF.text!
        userDetails["password"] = passwordTF.text!
        userDetails["mobileNumber"] = mobileNumberTF.text!
        userDetails.saveInBackgroundWithBlock {(succeeded, error) -> Void in
            
            if let error = error as NSError? {
                let errorString = error.userInfo["error"] as? NSString
                // In case something went wrong, use errorString to get the error
                self.displayAlertWithTitle("Something has gone wrong", message:"\(errorString)")
            } else {
                // Everything went okay
                self.displayAlertWithTitle("Success!", message:"Registration was successful")
                
                
                let emailVerified = userDetails["emailVerified"]
                if emailVerified != nil && (emailVerified as! Bool) == true {
                    // Everything is fine
                }
                else {
                    // The email has not been verified, so logout the user
                    PFUser.logOut()
                }
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

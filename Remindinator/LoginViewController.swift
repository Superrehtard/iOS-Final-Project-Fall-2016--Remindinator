//
//  ViewController.swift
//  Remindinator
//
//  Created by Parne,Pruthivi R on 10/23/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse


class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signInBTN(sender: AnyObject) {
       let query = PFQuery(className: "userDetails")
        query.whereKey(userNameTF.text!, equalTo: "emailID")
        query.whereKey(passwordTF.text!, equalTo: "password")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil{
                self.displayAlertWithTitle("Oops", message: error!.description)
            }
            else { // Everything went alright here
                self.displayAlertWithTitle("Success!", message:"Login successful")
            }

//            if error == nil {
//                func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//
//                let registerVC = segue.destinationViewController as! RegistrationViewController
//                }
//                            } else {
//                 self.displayAlertWithTitle("Oops", message: error!.description)
//            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       func displayAlertWithTitle(title:String, message:String){
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction:UIAlertAction =  UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
}
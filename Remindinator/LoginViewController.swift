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
        
        if PFUser.currentUser() != nil {
                self.performSegueWithIdentifier("LoginSuccessful", sender: self)
        }
        
    }
    
    @IBAction func signInBTN(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(userNameTF.text!, password: passwordTF.text!) {
            user, error in
            if user != nil {
                self.performSegueWithIdentifier("LoginSuccessful", sender: self)
            } else if let error = error {
                self.displayAlertWithTitle("Login Unsuccessful", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func logUserOut(segue: UIStoryboardSegue) {
        if PFUser.currentUser() != nil {
            PFUser.logOut()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        userNameTF.text = "iamparne"
        passwordTF.text = "parne007"
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
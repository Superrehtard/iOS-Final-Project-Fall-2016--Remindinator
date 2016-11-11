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
        
        self.navigationItem.title = "Sign Up"
    }
    
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var emailOrUserNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signUpBTN(sender: AnyObject) {
        let user = PFUser()
        // TO DO:
        // Implement validations (password matching etc..,)
        
        user.username = userNameTF.text!
        user.password = passwordTF.text!
        user.email = emailOrUserNameTF.text!
        
        let image = UIImage(named: "Gender Neutral User Filled-100")
        let imageData = UIImagePNGRepresentation(image!)
        let imageFile = PFFile(name: userNameTF.text!, data: imageData!)
        
        user["image"] = imageFile
        
        user.signUpInBackgroundWithBlock {
            succeded, error in
            if succeded {
                
                self.performSegueWithIdentifier("SignUpSuccessful", sender: self)
            } else {
                self.displayAlertWithTitle("Something gone awfully wrong!", message: "\(error!.localizedDescription)")
                
                let emailVerified = user["emailVerified"]
                if emailVerified != nil && (emailVerified as! Bool) == true {
                    // Everything is fine
                } else {
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

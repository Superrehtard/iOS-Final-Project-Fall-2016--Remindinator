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
        
        assignbackground()
        self.navigationItem.title = "Sign Up"
        
        
    }
    
    func assignbackground(){
        let background = UIImage(named: "Background1.png")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    // Outlets for the Registration View Controller.
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailOrUserNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function is called once the user taps on the signUp button. This function registers a user.
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
        
        user["firstName"] = firstNameTF?.text!
        user["lastName"] = lastNameTF?.text!
        
        var validNameEntered:Bool = false
        
        if firstNameTF?.text != "" && lastNameTF?.text != "" {
            validNameEntered = true
        }
        
        if passwordTF.text == confirmPasswordTF.text && validNameEntered {
            
            user.signUpInBackgroundWithBlock {
                succeded, error in
                if succeded {
//                    user.saveInBackground()
                    print(PFUser.currentUser()?.username)
                    self.performSegueWithIdentifier("SignUpSuccessful", sender: self)
                    
                } else {
                    self.displayAlertWithTitle("Whoops!", message: "\(error!.localizedDescription)")
                    
                    let emailVerified = user["emailVerified"]
                    if emailVerified != nil && (emailVerified as! Bool) == true {
                        // Everything is fine
                    } else {
                        // The email has not been verified, so logout the user
                        PFUser.logOut()
                    }
                }
            }
        }else{
            if passwordTF.text == confirmPasswordTF.text {
                displayAlertWithTitle("No Name?", message: "Please provide both first name and last name for the user")
            } else {
                displayAlertWithTitle("Error Signing up!", message: "Passwords did not match")
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

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
    
    // Outlets for userName and password fields.
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        assignbackground()
        
        // if there is user logged in already navigate to the dashboard.
        if PFUser.currentUser() != nil {
                self.performSegueWithIdentifier("LoginSuccessful", sender: self)
        }
        
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
    
    // Function is called when the user clicks on the sign In button. If the login is successful the user is navigated to the dashboard else an error message is displayed.
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
    
    // Unwind segue to log user out from the dashboard and user profile page.
    @IBAction func logUserOut(segue: UIStoryboardSegue) {
        if PFUser.currentUser() != nil {
            PFUser.logOut()
        }
        
    }
    
    // Setting the username and password field by default here to make it easy while developing.
    override func viewWillAppear(animated: Bool) {
        userNameTF.text = "iamparne"
        passwordTF.text = "parne007"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
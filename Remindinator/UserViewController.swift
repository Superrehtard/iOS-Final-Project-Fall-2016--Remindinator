//
//  UserViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 10/23/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import Parse

class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Outlets and stored properties.
    var userFullName:String!
    @IBOutlet weak var userProfileIV: UIImageView!
    @IBOutlet weak var userFullNameLBL: UILabel!
    
    // Function that pops this current viewcontroller taking back to Dashboard.
    @IBAction func backToDashboard(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // In this method we are making the user image interactive and setting default image for our user.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userProfileIV.layer.cornerRadius = self.userProfileIV.frame.size.height / 2
        self.userProfileIV.clipsToBounds = true
        
        self.userProfileIV.layer.borderWidth = 3
        self.userProfileIV.layer.borderColor = UIColor.whiteColor().CGColor
        self.userProfileIV.userInteractionEnabled = true
        let user = PFUser.currentUser()!
        if let userImageFile = user["image"] as? PFFile {
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.userProfileIV.image = UIImage(data:imageData)
                        
                    }
                } else {
                    print("Something has happened: \(error)")
                }
            }
        } else {
            let image = UIImage(named: "Gender Neutral User Filled-100")
            let imageData = UIImagePNGRepresentation(image!)
            let imageFile = PFFile(name: user.username, data: imageData!)
            
            self.userProfileIV.image = image
            
            user["image"] = imageFile
            
            user.saveInBackgroundWithBlock({(success,error)->Void in
                
                if error != nil {
                    print("Something has gone wrong saving in background: \(error)")
                } else {
                    print("Success while saving")
                }
                
                })
        }
        
        // Here we are setting the user full name to the current user's username.
        userFullNameLBL.text = PFUser.currentUser()?.username
        
        assignbackground()
    }
    
    func assignbackground(){
        let background = UIImage(named: "Background.png")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function is called whenever a user taps on the profile image.
    @IBAction func userImageTapped(gestureRecognizer: UIGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // This function tell what should be done once the user is done picking an image. This basically get the image and saves it in the backend to be retrieved later.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let imageData = UIImagePNGRepresentation(image!)
        let imageFile = PFFile(name: PFUser.currentUser()?.username!, data: imageData!)
        
        PFUser.currentUser()?["image"] = imageFile
        PFUser.currentUser()?.saveInBackgroundWithBlock({(success,error) in
            if error != nil {
                print("Something has gone wrong saving in background in imagePickerController(): \(error)")
            } else {
                print("Success while saving")
            }
            
        })

        
        userProfileIV.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Function to handle all the segues from the userViewController.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "myEvents"{
            
//        let dashBoardTVC = segue.destinationViewController as! myEventsTableTableViewController
        }
        if segue.identifier == "dashBoard"{
//        let myEventsTVC = segue.destinationViewController as! DashBooardTableViewController
        }
    }

}

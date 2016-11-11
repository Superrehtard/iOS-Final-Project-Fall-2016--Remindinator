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
    
    var userFullName:String!
    @IBOutlet weak var userProfileIV: UIImageView!

    @IBOutlet weak var userFullNameLBL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfileIV.userInteractionEnabled = true

        userFullNameLBL.text = PFUser.currentUser()?.username
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userImageTapped(gestureRecognizer: UIGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        userProfileIV.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "myEvents"{
            
//        let dashBoardTVC = segue.destinationViewController as! myEventsTableTableViewController
        }
        if segue.identifier == "dashBoard"{
//        let myEventsTVC = segue.destinationViewController as! DashBooardTableViewController
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

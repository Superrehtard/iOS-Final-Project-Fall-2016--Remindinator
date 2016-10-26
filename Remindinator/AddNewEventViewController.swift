//
//  AddNewEventViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 10/26/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit

class AddNewEventViewController: UIViewController {

    @IBOutlet weak var eventNameTF: UITextField!
    @IBOutlet weak var eventTimeTF: UITextField!
    @IBOutlet weak var eventLocTF: UITextField!
    
    @IBAction func addEvent(sender: AnyObject) {
        let dashboardEvent = DashboardEvent(name: eventNameTF.text, time: eventTimeTF.text, location: eventLocTF.text, user: PFUser.currentUser()!)
        
        dashboardEvent.saveInBackgroundWithBlock{ succeeded, error in
            if succeeded {
                //3
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                //4
                if let errorMessage = error?.userInfo["error"] as? String {
                    print(errorMessage)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

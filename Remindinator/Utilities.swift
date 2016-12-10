//
//  Utilities.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 12/9/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation

extension UIViewController {
    
    // Function that displays an Alert Message with the passed in title and message.
    func displayAlertWithTitle(title:String, message:String){
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction:UIAlertAction =  UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}

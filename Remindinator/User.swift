//
//  User.swift
//  Remindinator
//
//  Created by Peram,Vinod Kumar Reddy on 10/23/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation
class User{
    var firstName:String
    var lastName:String
    var emailId:String
    var password:String
    
    init(firstName:String, lastName:String, emailId:String, password:String){
        self.firstName = firstName
        self.lastName = lastName
        self.emailId = emailId
        self.password = password
    }
    
}
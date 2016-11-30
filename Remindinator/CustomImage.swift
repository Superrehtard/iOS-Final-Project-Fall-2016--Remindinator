//
//  CustomImage.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/30/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import Foundation

extension UIImage {
    func imageByApplyingClippingBezierPath(path: UIBezierPath) -> UIImage! {
        let frame = CGRectMake(0, 0, self.size.width, self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        path.addClip()
        self.drawInRect(frame)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        return newImage
    }
}
//
//  EventNameTableViewCell.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 11/6/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit

class EventNameTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let eventNameTF:UITextField
    
    var eventName: String? {
        didSet {
            eventNameTF.text = eventName
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // 1 Entire cell is set as textfield. Labels color & font is set.
        eventNameTF = UITextField(frame: CGRect.null)
        eventNameTF.textColor = UIColor.blackColor()
        eventNameTF.font = UIFont.systemFontOfSize(16)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 2 Label textfield delegate is TableViewCell. Label is aligned center in cell. If you omit this list then label will be at top part of each cell.
        eventNameTF.delegate = self
        eventNameTF.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        // 3 Label is added as subview
        addSubview(eventNameTF)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let leftMarginForLabel: CGFloat = 15.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventNameTF.frame = CGRect(x: leftMarginForLabel, y: 0, width: bounds.size.width - leftMarginForLabel, height: bounds.size.height)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if eventName != nil {
            eventName = textField.text
        }
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

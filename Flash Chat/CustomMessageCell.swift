//
//  CustomMessageCell.swift
//  Flash Chat
//
//  Created by Michael Gimara on 31/03/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
        
        
        
    }


}

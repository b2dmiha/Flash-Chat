//
//  Message.swift
//  Flash Chat
//
//  Created by Michael Gimara on 31/03/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

class Message {
    var messageBody = ""
    var sender = ""
    
    init(messageBody: String, sender: String) {
        self.messageBody = messageBody
        self.sender = sender
    }
}

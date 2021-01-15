//
//  MKMessage.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/12/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var messageId: String = ""
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitals: String
        
    var status: String
    var readDate: Date
    
    init(message: LocalMessage) {
        
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        self.senderInitals = message.senderinitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = FUser.currentId() != mkSender.senderId //translation
        
    }

}

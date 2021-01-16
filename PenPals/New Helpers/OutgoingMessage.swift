//
//  OutgoingMessage.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/14/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class OutgoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
        let currentUser = FUser.currentUser()!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.objectId
        message.senderName = currentUser.fullname
        message.senderinitials = String(currentUser.firstname.first!) + String(currentUser.lastname.first!)
        message.date = Date()
        message.status = kSENT
        
        if text != nil {
            
            //send text message
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        //TODO: SEND PUSH NOTIFICATION
        //TODO: UPDATE RECENT
    }
    
    class func sendMessage(message: LocalMessage, membersIds: [String]) {
        
        RealmManager.shared.saveToRealm(message)
        
        for memberId in membersIds {
            
            print("save message for \(memberId)")
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
            
        }
        
    }
    
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    
    message.message = text
    message.type = kTEXT
    
    //send text
    OutgoingMessage.sendMessage(message: message, membersIds: memberIds)
    
}

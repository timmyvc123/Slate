//
//  MessageDataSource.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/12/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import MessageKit

extension NewMessageViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return mkMessages[indexPath.section] //gets each message index (each message is given its own section index)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        mkMessages.count
        
    }
    
}

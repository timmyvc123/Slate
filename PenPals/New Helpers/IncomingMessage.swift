//
//  IncomingMessage.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/16/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
        
        init(_collectionView: MessagesViewController) {
            messageCollectionView = _collectionView
        }
    
    //MARK: - Create Message
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        
        let mkMessage = MKMessage(message: localMessage)
        
        //multimedia messages
        
        return mkMessage
        
    }
    
    
}

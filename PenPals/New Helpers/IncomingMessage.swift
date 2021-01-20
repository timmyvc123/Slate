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
        if localMessage.type == kPHOTO {
            
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (image) in
                
                mkMessage.photoItem?.image = image
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        return mkMessage
        
    }
    
    
}

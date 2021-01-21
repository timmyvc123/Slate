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
        
        if localMessage.type == kVIDEO {
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (thumbnail) in
                
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { (readyToPlay, fileName) in
                    
                    let videoURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                    
                    let videoItem = VideoMessage(url: videoURL)
                    
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                
                mkMessage.videoItem?.image = thumbnail
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kLOCATION {
            
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
            
        }
        
        if localMessage.type == kAUDIO {
            
            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))
            
            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)
            
            FileStorage.downloadAudio(audioLink: localMessage.audioUrl) { (fileName) in
                
                let audioURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                
                mkMessage.audioItem?.url = audioURL
            }
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
        return mkMessage
    }
}

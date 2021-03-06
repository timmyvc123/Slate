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
    
    //MARK: - Translation Vars
    var code = FUser.currentUserFunc()?.language
    let semaphore = DispatchSemaphore(value: 0)
    var translatedText = ""
    
    
    //MARK: - Create Message
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        
        let userId = localMessage.senderId
        let tempId = FUser.currentUserFunc()?.objectId
        
        var isCurrentUser: Bool = false
        
        if userId == tempId {
            isCurrentUser = true
        }
        
//        var test = String(describing: localMessage)
        var text = localMessage.message
        
        initiateTranslation(text: text, isCurrentUser: isCurrentUser) { (transText) in
            text = transText

            self.semaphore.signal()
        }
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        var mkMessage: MKMessage = MKMessage.init()
        if localMessage.senderId != FUser.currentId {
            mkMessage = MKMessage(message: localMessage, translatedText: text)
        }
        else {
            mkMessage = MKMessage(message: localMessage, translatedText: localMessage.message)

        }
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
    
    //MARK: Translation Code
    
    func detectlanguage(text: String, completion: @escaping ( _ result: String) -> ()) {

        TranslationManager.shared.detectLanguage(forText: text) { (language) in
            if let language = language {
                print("The detected language was \(language)")
                completion(language)
            } else {
                print("language code not detected")
            }
        }
    }
    
    func initiateTranslation(text: String, isCurrentUser: Bool, completion: @escaping ( _ result: String) -> ()) {
        var text = text
        if isCurrentUser {
            completion(text)
        } else {
            translate(text: text)
            TranslationManager.shared.translate { (translation) in
                if let translation = translation {
                    text = translation
                    print("The translation is... \(text)")
                    completion(text)
                } else {
                    print("language not translated")
                    self.semaphore.signal()
                }
                
            }
        }
    }
    
    func translate(text: String) {
        getTargetLangCode()
        TranslationManager.shared.textToTranslate = text
    }
    
    func getTargetLangCode() {
        if code == nil {
            code = FUser.currentUserFunc()?.language
        }
        TranslationManager.shared.targetLanguageCode = code
    }
      
}

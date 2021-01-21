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
import Gallery

class OutgoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
        let currentUser = FUser.currentUserFunc()!
        
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
        
        if photo != nil {
            //send photo message
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            //send video message
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        //TODO: SEND PUSH NOTIFICATION
        //UPDATE RECENT
        FirebaseRecentListener.shared.updateRecents(chatRomId: chatId, lastMessage: message.message)
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

func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String]) {

    message.message = "Picture Message"
    message.type = kPHOTO
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageURL) in
        
        if imageURL != nil {
            
            message.pictureUrl = imageURL!
            
            OutgoingMessage.sendMessage(message: message, membersIds: memberIds)
        }
    }
}

func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String]) {
    
    message.message = "Video Message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectoy = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    
    editor.process(video: video) { (processedVideo, videoUrl) in
        
        if let tempPath = videoUrl {
            
            let thumbnail = videoThumbnail(video: tempPath)
            
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectoy) { (imageLink) in
                
                if imageLink != nil {
                    
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { (videoLink) in
                        
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        OutgoingMessage.sendMessage(message: message, membersIds: memberIds)
                    }
                }
                
            }
        }
    }
}

func sendLocationMessage(message: LocalMessage, memberIds: [String]) {

    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    OutgoingMessage.sendMessage(message: message, membersIds: memberIds)

}

func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float, memberIds: [String]) {

    message.message = "Audio message"
    message.type = kAUDIO
    
    let fileDirectory =  "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"

    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { (audioUrl) in
        
        if audioUrl != nil {
            
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            
            
            OutgoingMessage.sendMessage(message: message, membersIds: memberIds)
        }
    }
    
    
}

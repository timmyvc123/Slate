//
//  FirebaseRecentListener.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/5/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import Firebase

class FirebaseRecentListener {
    
    static let shared = FirebaseRecentListener()
    
    private init() {}
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentNew]) ->Void) {
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: FUser.currentId).addSnapshotListener { (querySnapshot, error) in
            
            var recentChats: [RecentNew] = []
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent chats")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentNew? in
                return try? queryDocumentSnapshot.data(as: RecentNew.self)
            }
            
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
        }
    }
    
    func resetRecentCounter(chatRoomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: FUser.currentId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentNew? in
                return try? queryDocumentSnapshot.data(as: RecentNew.self)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentNew? in
                return try? queryDocumentSnapshot.data(as: RecentNew.self)
            }
            
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentNew, lastMessage: String) {
        
        var tempRecent = recent
        
        if tempRecent.senderId != FUser.currentId {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        tempRecent.actualSender = FUser.currentIdFunc()
        self.saveRecent(tempRecent)
    }
    
    func clearUnreadCounter(recent: RecentNew) {
        
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent)
    }
    
    func saveRecent(_ recent: RecentNew) {
        
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print("Error saving recent chat ", error.localizedDescription)
        }
    }
    
    func deleteRecent(_ recent: RecentNew) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
    
}

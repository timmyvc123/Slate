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
    
    func downloadRecentChatsFrmFirestore(completion: @escaping (_ allRecents: [RecentNew]) -> Void) {
        
        //get all recents that sender has
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: FUser.currentId()).addSnapshotListener { (querySnapshot, error) in
            
            var recentChats: [RecentNew] = []
            
            guard let documents = querySnapshot?.documents else {
                
                print("no documents for recent chats")
                return
            }
            
            //convert into recent objects to get a dictionary
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentNew? in
                return try? queryDocumentSnapshot.data(as: RecentNew.self)
            }
            
            //check which recents have a last message
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            //sort the recent objects
            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
        }
    }
    
    func resetRecentCounter(chatroomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatroomId).whereField(kSENDERID, isEqualTo: FUser.currentId()).getDocuments { (querySnapshot, error) in
            
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
    
    func clearUnreadCounter(recent: RecentNew) {
        
        var recent = recent
        recent.unreadCounter = 0
        self.saveRecent(recent)
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

//
//  StartChat.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/5/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import Firebase

//MARK: - StartChat
func startChat(user1: FUser, user2: FUser) -> String {
    
    let chatRoomId = chatRoomIdFrom(user1Id: user1.objectId, user2Id: user2.objectId)
    
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    
    FUser.downloadUsersFromFirebase(withIds: memberIds) { (users) in
        
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

func getReceiverFrom(users: [FUser]) -> FUser {
    
    var allUsers = users
    
    allUsers.remove(at: allUsers.firstIndex(of: FUser.currentUser!)!)
    
    return allUsers.first!
}

//MARK: - RecentChats

func createRecentItems(chatRoomId: String, users: [FUser]) {
    
    var memberIdsToCreateRecent = [users.first!.objectId, users.last!.objectId]
    
    print("Members to create recent is \(memberIdsToCreateRecent)")
    //does user have recent?
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
            print("updated members to create recent is \(memberIdsToCreateRecent)")
        }
        
        for userId in memberIdsToCreateRecent {
                        
            print("creating recent fr user with id \(userId)")
            let senderUser = userId == FUser.currentId ? FUser.currentUser! : getReceiverFrom(users: users)
            
            let receiverUser = userId == FUser.currentId ? getReceiverFrom(users: users) : FUser.currentUser!
            
            let recentObject = RecentNew(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.objectId, senderName: senderUser.fullname, recieverId: receiverUser.objectId, recieverName: receiverUser.fullname, date: Date(), memberIds: [senderUser.objectId, receiverUser.objectId], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatar)
            
            FirebaseRecentListener.shared.saveRecent(recentObject)
        }
        
    }
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    
    var memberIdsToCreateRecent = memberIds
    
    for recentData in snapshot.documents {
        
        let currentRecent = recentData.data() as Dictionary
        
        if let currentUserId = currentRecent[kSENDERID] {
            
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    
    return memberIdsToCreateRecent
}


func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue
    
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    
    return chatRoomId
}


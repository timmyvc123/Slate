//
//  StartChat.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/5/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import Firebase

//MARK: - Start Chat

//called when user starts a chat with another user
func startChat(user1: FUser, user2: FUser) -> String {

    let chatRoomId = chatRoomIdFrom(user1Id: user1.objectId, user2Id: user2.objectId)
        
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
        
    return chatRoomId
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    
    getUsersFromFirestore(withIds: memberIds) { (users) in
        
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

func getReceiverFrom(users: [FUser]) -> FUser {
    
    var allUsers = users
    
    allUsers.remove(at: allUsers.firstIndex(of: FUser.currentUser()!)!)
    
    return allUsers.first!
}

//MARK: - RecentChats

//creates chatroom for each user in conversation
func createRecentItems(chatRoomId: String, users: [FUser]) {

    var memberIdsToCreateRecent = [users.first!.objectId, users.last!.objectId]

    print("Members to create recent is \(memberIdsToCreateRecent)")
    //check if there is a recent already
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in

        guard let snapshot = snapshot else { return }

        if !snapshot.isEmpty {
            
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
            
            print("updated members to create recent is \(memberIdsToCreateRecent)")

        }

        //create recent bject for the sender and receiver
        for userId in memberIdsToCreateRecent {
            
            print("creating recent fr user with id \(userId)")

            //check if current user is the sender
            let senderUser = userId == FUser.currentId() ? FUser.currentUser()! : getRecieverFrom(users: users)

            let recieverUser = userId == FUser.currentId() ? getRecieverFrom(users: users) : FUser.currentUser()!

            let recentObject = RecentNew(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.objectId, senderName: senderUser.fullname, recieverId: recieverUser.objectId, recieverName: recieverUser.fullname, date: Date(), memberIds: [senderUser.objectId, recieverUser.objectId], lastMessage: "", unreadCounter: 0, avatarLink: recieverUser.avatar)

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

//creates two chatrooms (one for each user in the conversation) using the current users id + the user's ID that they're chatting with
func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {

    var chatRoomId = ""

    let value = user1Id.compare(user2Id).rawValue

    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)

    return chatRoomId
}

func getRecieverFrom(users: [FUser]) -> FUser {

    var allUsers = users

    allUsers.remove(at: allUsers.firstIndex(of: FUser.currentUser()!)!)

    return allUsers.first!
}


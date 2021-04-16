//
//  FirebaseMessageListener.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/15/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    
    static let shared = FirebaseMessageListener()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    
    private init() { }
    
    
//    func updateTranslatedText(_ documentId: String, collectionId: String, lastMessageDate: Date) {
//        FirebaseReference(.Messages).document(documentId).collection(collectionId).
//    }
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        
        //listen for any changes in database
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            
            guard let snapshot = querySnapshot else { return }
            
            // checkif change was added t database
            for change in snapshot.documentChanges {
                
                if change.type == .added {
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    //if succesful save to local realm database or print error message
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject {
                            
                            if message.senderId != FUser.currentId {
                                RealmManager.shared.saveToRealm(message)
                            }
                            
                        } else {
                            print("Document doesnt exist")
                        }
                        
                    case .failure(let error):
                        print("Error decoding local message: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        
        updatedChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ (querySnapshot, error) in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                
                if change.type == .modified {
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject {
                            completion(message)
                        } else {
                            print("Document does not exist in chat")
                        }
                        
                    case .failure(let error):
                        
                        print("Error decoding local message: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    func checkForOldChats(_ documentId: String, collectionId: String) {
        
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for old chats")
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: { $0.date < $1.date })
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
        }
        
    }
    
    //MARK: - Add, Update, Delete
    
    //gets message and saves it for specific user
    func addMessage(_ message: LocalMessage, memberId: String) {
        
        do {
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch {
            print("error saving messsage ", error.localizedDescription)
        }
        
    }
    
    //MARK: - Update Message Status
    func updateMessageInFirebase(_ message: LocalMessage, memberIds: [String]) {
        
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]
        
        for userId in memberIds {
            FirebaseReference(.Messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }
    
    func removeListener() {
        self.newChatListener.remove()
//        self.updatedChatListener.remove()
    }
    
}

//
//  FirebaseTypingListener.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/19/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import Firebase

class FirebaseTypingListener {
    
    static let shared = FirebaseTypingListener()
    var typingListener: ListenerRegistration!
    
    private init() { }
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        
        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                for data in snapshot.data()! {
                    
                    if data.key != FUser.currentId {
                        completion(data.value as! Bool)
                    }
                }
                
            } else {
                completion(false)
                FirebaseReference(.Typing).document(chatRoomId).setData([FUser.currentId : false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        
        FirebaseReference(.Typing).document(chatRoomId).updateData([FUser.currentId : typing])
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
}

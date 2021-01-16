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
    
    private init() { }
    
    //MARK: - Add, Update, Delete
    
    //gets message and saves it for specific user
    func addMessage(_ message: LocalMessage, memberId: String) {
        
        do {
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch {
            print("error saving messsage ", error.localizedDescription)
        }
        
    }
    
    
    
}

//
//  FirebaseUserListener.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/5/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init () {}
    
    //MARK: - Download
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [FUser]) -> Void) {
           
           var count = 0
           var usersArray: [FUser] = []
           
           for userId in withIds {
               
               FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                   
                   guard let document = querySnapshot else {
                       print("no document for user")
                       return
                   }
                   
                   let user = try? document.data(as: FUser.self)

                   usersArray.append(user!)
                   count += 1
                   
                   
                   if count == withIds.count {
                       completion(usersArray)
                   }
               }
           }
       }
}


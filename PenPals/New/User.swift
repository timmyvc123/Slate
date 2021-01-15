//
//  User.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 11/13/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//


import Foundation
import Firebase
import FirebaseFirestoreSwift


struct User: Codable, Equatable {
    
    var id = ""
    var firstName: String
    var lastName: String
    var email: String
    var language: String
    var pushId = ""
    var avatarLink = ""
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user from user defaults ", error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}



func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("error saving user locally ", error.localizedDescription)
    }
}


//func createDummyUsers() {
//    print("creating dummy users...")
//
//    let names = ["Alison Stamp", "Inayah Duggan", "Alfie Thornton", "Rachelle Neale", "Anya Gates", "Juanita Bate"]
//
//    var imageIndex = 1
//    var userIndex = 1
//
//    for i in 0..<5 {
//
//        let id = UUID().uuidString
//
//        let fileDirectory = "Avatars/" + "_\(id)" + ".jpd"
//
//        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
//
//            let user = User(id: id, firstName: names[i], email: "user\(userIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "", status: "No Status")
//
//            userIndex += 1
//            FirebaseUserListener.shared.saveUserToFireStore(user)
//        }
//
//        imageIndex += 1
//        if imageIndex == 5 {
//            imageIndex = 1
//        }
//    }
//
//}

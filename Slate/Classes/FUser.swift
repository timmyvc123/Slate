//
//  FUser.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/6/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

// FILE THAT HOLDS ALL VARIABLES EACH USER HAS

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FUser: Codable, Equatable {
    
    
    static func == (lhs: FUser, rhs: FUser) -> Bool {
        lhs.objectId == rhs.objectId
    }
    
    
    // firebase creates an unique Id for every user
    let objectId: String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    var email: String
    var firstname: String
    var lastname: String
    var fullname: String
    var avatar: String
    var phoneNumber: String
    var language: String
    
    var contacts: [String]
    var blockedUsers: [String]
    let loginMethod: String
    var friendListIds: [String]
    
    //MARK: Initializers
    
    // standard initializier to give objects to user
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _email: String, _firstname: String, _lastname: String, _avatar: String = "", _loginMethod: String, _phoneNumber: String, _language: String) {
        
        objectId = _objectId
        pushId = _pushId
        
        createdAt = _createdAt
        updatedAt = _updatedAt
        
        email = _email
        firstname = _firstname
        lastname = _lastname
        fullname = _firstname + " " + _lastname
        avatar = _avatar
        
        language = _language
        
        loginMethod = _loginMethod
        phoneNumber = _phoneNumber
        blockedUsers = []
        contacts = []
        friendListIds = []
        
    }
    
    
    // all users are saved as dictionaries
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        // checks to see if User's variables are empty strings so we can set them to empty strings to avoid app crashing
        if let created = _dictionary[kCREATEDAT] {
            if (created as! String).count != 14 {
                createdAt = Date()
            } else {
                createdAt = dateFormatter().date(from: created as! String)!
            }
        } else {
            createdAt = Date()
        }
        if let updateded = _dictionary[kUPDATEDAT] {
            if (updateded as! String).count != 14 {
                updatedAt = Date()
            } else {
                updatedAt = dateFormatter().date(from: updateded as! String)!
            }
        } else {
            updatedAt = Date()
        }
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        if let fname = _dictionary[kFIRSTNAME] {
            firstname = fname as! String
        } else {
            firstname = ""
        }
        if let lname = _dictionary[kLASTNAME] {
            lastname = lname as! String
        } else {
            lastname = ""
        }
        fullname = firstname + " " + lastname
        if let avat = _dictionary[kAVATAR] {
            avatar = avat as! String
        } else {
            avatar = ""
        }
        if let phone = _dictionary[kPHONE] {
            phoneNumber = phone as! String
        } else {
            phoneNumber = ""
        }
        if let cont = _dictionary[kCONTACT] {
            contacts = cont as! [String]
        } else {
            contacts = []
        }
        if let block = _dictionary[kBLOCKEDUSERID] {
            blockedUsers = block as! [String]
        } else {
            blockedUsers = []
        }
        
        if let lgm = _dictionary[kLOGINMETHOD] {
            loginMethod = lgm as! String
        } else {
            loginMethod = ""
        }
        if let lang = _dictionary[kLANGUAGE] {
            language = lang as! String
        } else {
            language = ""
        }
        if let friends = _dictionary[kFRIENDLISTIDS] {
            friendListIds = friends as! [String]
        } else {
            friendListIds = []
        }
        
    }
    
    
    //MARK: Returning current user funcs
    
    // checks current user logged in and returns their current ID
    
    class func currentIdFunc() -> String {
        
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUserFunc() -> FUser? {
        
        if Auth.auth().currentUser != nil {
            
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                
                return FUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }    
    
    //MARK: Login function
    
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        // Firebase login function with email and password
        Auth.auth().signIn(withEmail: email, password: password, completion: { (firUser, error) in
            
            if error != nil {
                // pass error through
                completion(error)
                return
                
            } else {
                //get user from firebase and save locally
                //fetchCurrentUserFromFirestore(userId: firUser!.user.uid)
                FirebaseReference(.User).document(firUser!.user.uid).getDocument { (snapshot, error) in
                    
                    guard let snapshot = snapshot else {  return }
                    
                    // if there is a user that matches an id...
                    if snapshot.exists {
                        print("updated current users param")
                        
                        // save the user Id locally as the current user
                        UserDefaults.standard.setValue(snapshot.data()! as NSDictionary, forKeyPath: kCURRENTUSER)
                        UserDefaults.standard.synchronize()
                        completion(error)
                    }
                    
                }
                
            }
            
        })
        
    }
    
    //MARK: Register functions
    
    class func registerUserWith(email: String, password: String, firstName: String, lastName: String, avatar: String = "", language: String = "", completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (firuser, error) in
            
            if error != nil {
                
                completion(error)
                return
            }
            
            let fUser = FUser(_objectId: firuser!.user.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: firuser!.user.email!, _firstname: firstName, _lastname: lastName, _avatar: avatar, _loginMethod: kEMAIL, _phoneNumber: "", _language: "")
            
            saveUserLocally(fUser: fUser)
            saveUserToFirestore(fUser: fUser)
            completion(error)
            
        })
        
    }
    
    //MARK: - Download
    class func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [FUser]) -> Void) {
        
        var count = 0
        var usersArray: [FUser] = []
        
        //go through each user and download it from firestore
        for userId in withIds {
            
            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {  return }
                
                if snapshot.exists {
                    
                    let user = FUser(_dictionary: snapshot.data() as! NSDictionary)
                    count += 1
                    
                    //dont add if its current user
                  //  if user.objectId != FUser.currentId {
                        usersArray.append(user)
                   // }
                    
                } else {
                    completion(usersArray)
                }
                
                if count == withIds.count {
                    //we have finished, return the array
                    completion(usersArray)
                }
                
            }
            
        }
    }
    
    //MARK: LogOut func
    
    class func logOutCurrentUser(completion: @escaping (_ success: Bool) -> Void) {
        
        
        userDefaults.removeObject(forKey: kPUSHID)
        
        //remove the object that corresponds to the current user saved in user defaults
        userDefaults.removeObject(forKey: kCURRENTUSER)
        //save it
        userDefaults.synchronize()
        
        // logout user
        do {
            try Auth.auth().signOut()
            
            //complete the logout
            completion(true)
            
        } catch let error as NSError {
            completion(false)
            print(error.localizedDescription)
            
        }
        
        
    }
    
    //MARK: Delete user
    
    class func deleteUser(completion: @escaping (_ error: Error?) -> Void) {
        
        let user = Auth.auth().currentUser
        
        user?.delete(completion: { (error) in
            
            completion(error)
        })
        
    }
    
    //MARK: Password Reset
    
    func resetpassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        //        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
        
        //            if error == nil {
        //                onSuccess()
        //            } else {
        //                onError(error!.localizedDescription)
        //            }
        //
        //        }
        
    }
    
    
    
} //end of class funcs



//MARK: Save user funcs

func saveUserToFirestore(fUser: FUser) {
    FirebaseReference(.User).document(fUser.objectId).setData(userDictionaryFrom(user: fUser) as! [String : Any]) { (error) in
        
        print("error is \(String(describing: error?.localizedDescription))")
    }
}


func saveUserLocally(fUser: FUser) {
    
    UserDefaults.standard.set(userDictionaryFrom(user: fUser), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}


//MARK: Fetch User funcs

//New firestore
func fetchCurrentUserFromFirestore(userId: String) {
    
    // check reference in databse and search for user logging in that matches the Id
    // in the database collection "User"
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {  return }
        
        // if there is a user that matches an id...
        if snapshot.exists {
            print("updated current users param")
            
            // save the user Id locally as the current user
            UserDefaults.standard.setValue(snapshot.data()! as NSDictionary, forKeyPath: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            
        }
        
    }
    
}


func fetchCurrentUserFromFirestore(userId: String, completion: @escaping (_ user: FUser?)->Void) {
    
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {  return }
        
        if snapshot.exists {
            
            let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
            completion(user)
        } else {
            completion(nil)
        }
        
    }
}

//MARK: Helper funcs

func userDictionaryFrom(user: FUser) -> NSDictionary {
    
    let createdAt = dateFormatter().string(from: user.createdAt)
    let updatedAt = dateFormatter().string(from: user.updatedAt)
    
    return NSDictionary(objects: [user.objectId, user.pushId!, createdAt, updatedAt, user.email, user.loginMethod, user.firstname, user.lastname, user.fullname, user.avatar, user.contacts, user.blockedUsers, user.phoneNumber, user.friendListIds], forKeys: [kOBJECTID as NSCopying, kPUSHID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kAVATAR as NSCopying, kCONTACT as NSCopying, kBLOCKEDUSERID as NSCopying, kPHONE as NSCopying, kFRIENDLISTIDS as NSCopying])
    
    //kFRIENDLISTIDS = "friendListIds"
}

func getUsersFromFirestore(withIds: [String], completion: @escaping (_ usersArray: [FUser]) -> Void) {
    
    var count = 0
    var usersArray: [FUser] = []
    
    //go through each user and download it from firestore
    for userId in withIds {
        
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {  return }
            
            if snapshot.exists {
                
                let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
                count += 1
                
                //dont add if its current user
                if user.objectId != FUser.currentId {
                    usersArray.append(user)
                }  
                
            } else {
                completion(usersArray)
            }
            
            if count == withIds.count {
                //we have finished, return the array
                completion(usersArray)
            }
            
        }
        
    }
}


func updateCurrentUserInFirestore(withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
    
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        
        var tempWithValues = withValues
        
        let currentUserId = FUser.currentId
        
        let updatedAt = dateFormatter().string(from: Date())
        
        tempWithValues[kUPDATEDAT] = updatedAt
        
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        userObject.setValuesForKeys(tempWithValues)
        
        FirebaseReference(.User).document(currentUserId).updateData(withValues) { (error) in
            
            if error != nil {
                
                completion(error)
                return
            }
            
            //update current user
            UserDefaults.standard.setValue(userObject, forKeyPath: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            
            completion(error)
        }
        
    }
}

//MARK: Chaeck User block status

func checkBlockedStatus(withUser: FUser) -> Bool {
    return withUser.blockedUsers.contains(FUser.currentId)
}



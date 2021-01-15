//
//  RealmManager.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/14/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() { }
    
    //doesnt care what the object type is, as lng as it follows the protocol
    
    func saveToRealm<T: Object>(_ object: T) {
        
        do {
            
            try realm.write {
                realm.add(object, update: .all)
            }
            
        } catch {
            
            print("Error saving realm object ", error.localizedDescription)
            
        }
        
    }
}

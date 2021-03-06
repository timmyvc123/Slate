//
//  CollectionReference.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/7/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import FirebaseFirestore

// IMPORTING FIREBASE

enum FCollectionReference: String {
    // MAIN COLLECTION TITLES IN DATABASE
    case User
    case Typing
    case Recent
    case Messages
    case Group
    case Call
}

// returns path to database location
func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}

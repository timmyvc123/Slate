//
//  FCollectionReference.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 11/13/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FirebaseCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
    case Channel
}

func FirebaseReference(_ collectionReference: FirebaseCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}


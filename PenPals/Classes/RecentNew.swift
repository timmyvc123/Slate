//
//  RecentNew.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/2/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentNew: Codable {
    
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var recieverId = ""
    var recieverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
}

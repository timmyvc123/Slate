//
//  RecentChats.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 11/11/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentChats: Codable {
    
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

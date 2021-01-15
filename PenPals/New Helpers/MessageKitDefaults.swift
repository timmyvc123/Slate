//
//  MessageKitDefaults.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/12/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    //message bubble colors
    static let bubbleColorOutgoing = UIColor(named: "chatOutgoingBubble") ?? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static let bubbleColorIncming = UIColor(named: "chatIncomingBubble") ?? UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
}

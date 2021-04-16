//
//  AudioMessage.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/20/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {
    
    var url: URL
    var duration: Float
    var size: CGSize
    override init() {
        url = URL.init(string: "https://www.google.com")!
        duration = 0.0
        size = CGSize.init()
        super.init()

    }

    init(duration: Float) {
        
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
    
    
}
